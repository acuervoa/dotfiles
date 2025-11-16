# git.sh
# shellcheck shell=bash
# Helpers

# @cmd _git_root_or_die   Asegura que estamos en un repo git
_git_root_or_die() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'No estás en un repo git.\n' >&2
    return 1
  fi
}

# @cmd _git_main_branch   Detecta rama principal (main/master o HEAD remoto)
_git_main_branch() {
  if git show-ref --verify --quiet refs/heads/main; then
    printf 'main'
    return 0
  fi

  if git show-ref --verify --quiet refs/heads/master; then
    printf 'master'
    return 0
  fi

  local remote_head
  remote_head="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [ -n "$remote_head" ]; then
    printf '%s\n' "$remote_head" | sed 's#.*/##'
    return 0
  fi

  printf 'No puedo determinar la rama principal (main/master/origin/HEAD).\n' >&2
  return 1
}

# @cmd _git_switch  Wrapper seguro para cambiar de rama
# Usa git switch si existe, si no git checkout
_git_switch() {
  local target="$1"
  if git help -a | grep -qE '^\s+switch$'; then
    git switch -- "$target"
  else
    git checkout "$target"
  fi
}

# @cmd _git_switch_new  Wrapper seguro para crear rama desde otra ref
_git_switch_new() {
  local new_branch="$1"
  local from="$2"
  if git help -a | grep -qE '^\s+switch$'; then
    git switch -c "$new_branch" "$from"
  else
    git checkout -b "$new_branch" "$from"
  fi
}

# @cmd grt  Ir a la raiz del repo
grt() {
  _req git || return 1
  _git_root_or_die || return 1

  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  builtin cd -- "$root" || {
    printf 'No puedo hacer cd a %s\n' "$root" >&2
    return 1
  }
}

# @cmd gbr  Checkout rápido de rama (local o remota) con creación automática
# - Eliges entre ramas locales y remotas (se elimina el prefijo origin/)
# - Si no existe localmente pero sí en origin, crea rama de tracking
# - Si no existe en ningún sitio, te ofrece crearla desde HEAD actual
# - unifica "cámbiame a rama X" y "créame rama feature/X" en una sola acción
gbr() {
  _req git fzf || return 1
  _git_root_or_die || return 1

  local branch
  branch="$(
    {
      git for-each-ref --format='%(refname:short)' refs/heads
      git for-each-ref --format='%(refname:short)' refs/remotes |
        sed 's#^origin/##'
    } |
      sort -u |
      fzf --prompt=' branch > ' --ansi \
        --preview='git log --oneline --decorate --graph -n 20 {}' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$branch" ] && return 0

  if git rev-parse --verify "$branch" >/dev/null 2>&1; then
    _git_switch "$branch"
    return
  fi

  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    _git_switch_new "$branch" "origin/$branch"
    return
  fi

  printf 'Rama "%s" no existe. Se creará desde HEAD actual.\n' "$branch" >&2
  _confirm '¿Continuar? [y/N] ' || return 0
  _git_switch_new "$branch" HEAD
}

# @cmd gstaged  Que vamos a commitear realmente (diff staged bonito)
gstaged() {
  _req git || return 1
  _git_root_or_die || return 1

  git diff --cached --color=always
}

# @cmd gundo  Deshacer el último commit pero mantener los cambios en el working directory
# - soft reset seguro
gundo() {
  _req git || return 1
  _git_root_or_die || return 1

  printf 'Esto hará: git reset --soft HEAD~1 (deshace el último commit pero conserva los cambios).\n' >&2
  _confirm || return 0
  printf 'Ejecutando git reset --soft HEAD~1\n'
  git reset --soft HEAD~1
}

# @cmd gcof   Checkout de rama con preview del histórico
# - Comprueba que estás en un repo git.
# - Incluye rama actual destacada
# - Evita fallo si no eliges nada
# shellcheck disable=SC2016
gcof() {
  _req git fzf || return 1
  _git_root_or_die || return 1

  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

  local target
  target="$(
    git for-each-ref --sort=-committerdate \
      --format='%(objectname:short)|%(refname:short)|%(committerdate:relative)|%(authorname)|%(subject)' refs/heads |
      awk -F'|' '{ OFS="|"; print }' |
      fzf \
        --with-nth=2,3,4,5 \
        --delimiter='|' \
        --prompt=' checkout > ' \
        --header="Rama actual: ${current}" \
        --preview='hash=$(printf "%s\n" {} | cut -d"|" -f1 | tr -d "[:space:]");
            [ -z "$hash" ] && exit 0;
            git log -n 20 --oneline --decorate --graph --color=always "$hash"
        ' \
        --preview-window=right,70% |
      sed 's/^\* //' |
      cut -d'|' -f2
  )" || true

  if [ -z "$target" ]; then
    printf 'Sin selección. Nada que hacer. \n' >&2
    return 0
  fi

  _git_switch "$target"
}

# @cmd gclean   Limpia ramas locales ya mergeadas en la rama base
gclean() {
  _req git fzf || return 1
  _git_root_or_die || return 1

  git fetch --all --prune >/dev/null 2>&1

  local base current branches sel
  base="$(_git_main_branch)" || {
    printf 'No puedo determinar rama base. Abortando limpieza.\n' >&2
    return 1
  }

  if ! git rev-parse --verify "$base" >/dev/null 2>&1; then
    printf 'Rama base "%s" no existe localmente. Haz primero:\n git fetch origin %s:%s\n' "$base" "$base" "$base" >&2
    return 1
  fi

  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

  branches="$(
    git branch --merged "$base" 2>/dev/null |
      sed 's/^[* ] *//' |
      grep -v -E "^(${base}|${current})$" || true
  )"

  if [ -z "$branches" ]; then
    printf 'No hay ramas mergeadas para borrar.\n' >&2
    return 0
  fi

  sel="$(
    printf '%s\n' "$branches" |
      fzf --multi \
        --prompt=' gclean > ' \
        --header="Ramas mergeadas en ${base} (SPACE marca, ENTER confirma)"
  )" || return 0

  [ -z "$sel" ] && return 0

  printf 'Vas a borrar localmente:\n%s\n' "$sel" >&2
  if ! _confirm '¿Continuar? [y/N] '; then
    return 0
  fi

  local br
  while IFS= read -r br; do
    [ -z "$br" ] && continue
    git branch -d -- "$br"
  done <<<"$sel"
}

# @cmd watchdiff  Watcher de cambios locales en vivo
# - Refresca cada 2s
# - Muestra status corto + diff truncado
watchdiff() {
  _req git || return 1
  _git_root_or_die || return 1

  while true; do
    tput clear || clear
    local _root _branch _now
    _root="$(git rev-parse --show-toplevel)"
    _branch="$(git rev-parse --abbrev-ref HEAD)"
    _now="$(date +'%Y-%m-%d %H:%M:%S')"

    printf "Repo: %s\nRama: %s\nHora: %s\n\n" "$_root" "$_branch" "$_now"

    git status --short
    echo
    echo "---- cambios no stageados (hasta 200 líneas) -----"
    git diff --color=always | sed -n '1,200p'
    sleep 2
  done
}

# @cmd checkpoint   Guarda el stash de trabajo con nombre legible
checkpoint() {
  _req git || return 1
  _git_root_or_die || return 1

  local msg="${*:-work-in-progress}"

  git add -A
  git stash push --include-untracked -m "$msg"

  printf "✔ Guardado como checkpoint: %s\n" "$msg" >&2
  git stash list | head -n 5
}

# @cmd wip  Commit rapido "Work in progress"
# - despues reescribir con rebase -i  o  git commit --amend
wip() {
  _req git || return 1
  _git_root_or_die || return 1

  git add -A
  git commit -m "WIP $(date +'%Y-%m-%d %H:%M')" || {
    printf 'Nada que commitear.\n' >&2
    return 0
  }
  printf '✔ WIP guardado.\n' >&2
}

# @cmd fixup  Generear commits "fixup!" contra el ultimo commit
# - Para luego hacer autosquash en un rebase interactivo
fixup() {
  _req git || return 1
  _git_root_or_die || return 1

  local target msg
  target="${1:-HEAD}"

  if [ "$target" = "HEAD" ]; then
    msg="$(git log -1 --pretty=format:'%s')"
  else
    msg="$(git log -1 --pretty=format:'%s' "$target")"
  fi

  printf 'Creando commit fixup! para: %s\n' "$msg" >&2
  git commit --fixup "$target" || {
    printf 'Nada que fixupear.\n' >&2
    return 0
  }

  printf '✔ fixup! -> %s\n' "$msg" >&2
  printf 'Para plegar historia luego:\n  git rebase -i --autosquash <base>\n' >&2
}

# @cmd recent   Archivos tocados recientemente (últimos 3 días)
# - Selección con fzf
# - Preview con bat
# - Abre en tu editor
recent() {
  _req git fzf bat || return 1
  _git_root_or_die || return 1

  local file
  file="$(
    git log --name-only --pretty=format: --since='3 days ago' |
      sed '/^$/d' |
      sort -u |
      fzf --prompt='🕑 recientes > ' \
        --preview='bat --style=numbers --color=always {} 2>/dev/null | head -500' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$file" ] && return 0

  _edit_at "$file"
}

# @cmd gp   Push protegido
# - Muestra rama actual
# - Si el push falla por falta de upstream, lo crea
gp() {
  _req git || return 1
  _git_root_or_die || return 1

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 1

  printf 'Rama actual: %s\n' "$branch" >&2

  printf 'Vas a pushear la rama "%s".\n' "$branch" >&2
  _confirm '¿Seguro? [y/N] ' || return 0
  if git push; then
    return 0
  fi

  printf 'Push directo falló. Intento crear upstream: origin/%s\n' "$branch" >&2
  git push -u origin "$branch"
}

# @cmd branch   Lista ramas (locales y remotas) ordenadas por última actividad
branch() {
  _req git || return 1
  _git_root_or_die || return 1

  git for-each-ref --sort=-committerdate \
    --format='%(refname:short)|%(committerdate:relative)|%(authorname)|%(subject)' refs/heads refs/remotes |
    column -t -s'|'
}
