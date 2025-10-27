# git.sh

# Helpers

# Asegura que estamos en un repo git
_git_root_or_die() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'No estás en un repo git.\n' >&2
    return 1
  fi
}

# Detecta rama principal (main/master o HEAD remoto)
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

# Wrapper seguro para cambiar de rama
# Usa git switch si existe, si no git checkout
_git_switch() {
  local target="$1"
  if git help -a | grep -qE '^\s+switch$'; then
    git switch -- "$target"
  else
    git checkout -- "$target"
  fi
}

# Wrapper seguro para crear rama desde otra ref
_git_switch_new() {
  local new_branch="$1"
  local from="$2"
  if git help -a | grep -qE '^\s+switch$'; then
    git switch -c "$new_branch" "$from"
  else
    git checkout -b "$new_branch" "$from"
  fi
}

# Ir a la raiz del repo
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

# Checkout rápido de rama (local o remota) con creación automática
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

  printf 'Rama "%s" no existe. ¿Crear desde HEAD actual? [y/N] ' "$branch" >&2
  read -r ans
  [ "$ans" = "y" ] || return 0
  _git_switch_new "$branch" HEAD
}

# Que vamos a commitear realmente (diff staged bonito)
gstaged() {
  _req git bat || return 1
  _git_root_or_die || return 1

  git diff --cached --color=always
}

# Deshacer el último commit pero mantener los cambios en el working directory
# - soft reset seguro
gundo() {
  _req git || return 1
  _git_root_or_die || return 1

  printf 'Esto hará: git reset --soft HEAD~1 (deshace el último commit pero conserva los cambios).\n' >&2
  printf '¿Continuar? [y/N] ' >&2
  read -r ans
  [ "$ans" = "y" ] || return 0

  git reset --soft HEAD~1
}

# Checkout de rama con preview del histórico
# - Comprueba que estás en un repo git.
# - Incluye rama actual destacada
# - Evita fallo si no eliges nada

gcof() {
  _req git fzf || return 1
  _git_root_or_die || return 1

  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

  local branch
  branch="$(
    git for-each-ref --format='%(refname:short)' refs/heads |
      sed '/^$/d' |
      fzf --ansi \
        --prompt=' branch > ' \
        --header="Actual: ${current}" \
        --preview='git log --oneline --decorate --graph -n 30 {}' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$branch" ] && return 0

  _git_switch "$branch"
}

# Limpia ramas locales ya mergeadas
gclean() {
  _req git || return 1
  _git_root_or_die || return 1

  git fetch --all --prune >/dev/null 2>&1

  local base
  base="$(_git_main_branch)" || {
    printf 'No puedo determinar rama base. Abortando limpieza.\n' >&2
    return 1
  }

  if ! git rev-parse --verify "$base" >/dev/null 2>&1; then
    printf 'Rama base "%s" no existe localmente. Haz primero:\n  git fetch origin %s:%s\n' "$base" "$base" "$base" >&2
    return 1
  fi

  local current
  current="$(git rev-parse --abbrev-ref HEAD)"

  local merged
  merged="$(
    git branch --merged "$base" |
      sed 's/^[* ] *//' |
      grep -v "^$base$" |
      grep -v "^$current$"
  )"

  if [ -z "$merged" ]; then
    printf 'No hay ramas mergeadas para limpiar.\n' >&2
    return 0
  fi

  printf 'Las siguientes ramas ya están mergeadas en %s:\n' "$base" >&2
  printf '%s\n' "$merged" >&2
  printf '¿Borrarlas localmente con "git branch -d"? [y/N] ' >&2
  read -r ans
  [ "$ans" = "y" ] || return 0

  printf '%s\n' "$merged" | while read -r br; do
    [ -z "$br" ] && continue
    git branch -d "$br"
  done
}

# Watcher de cambios locales en vivo
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

# Guarda el stash de trabajo con nombre legible

checkpoint() {
  _req git || return 1
  _git_root_or_die || return 1

  local msg="${*:-work-in-progress}"

  git stash push --include-untracked -m "$msg"

  printf "✔ Guardado como checkpoint: %s\n" "$msg" >&2
  git stash list | head -n 5
}

# Commit rapido "Work in progress"
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

# Generear commits "fixup!" contra el ultimo commit
# - Para luego hacer autosquash en un rebase interactivo
fixup() {
  _req git || return 1
  _git_root_or_die || return 1

  local target msg
  target="$(git rev-parse --verify HEAD)" || return 1
  msg="$(git log -1 --pretty=format:%s)"

  git add -A
  git commit --fixup "$target" || {
    printf 'Nada que fixupear.\n' >&2
    return 0
  }

  printf '✔ fixup! -> %s\n' "$msg" >&2
  printf 'Para plegar historia luego:\n  git rebase -i --autosquash <base>\n' >&2
}

# Archivos tocados recientemente (últimos 3 días)
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

# Push protegido
# - Muestra rama actual
# - Si el push falla por falta de upstream, lo crea
gp() {
  _req git || return 1
  _git_root_or_die || return 1

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 1

  printf 'Vas a pushear la rama "%s". ¿Seguro? [y/N] ' "$branch" >&2
  read -r ans
  [ "$ans" = "y" ] || return 0

  if git push; then
    return 0
  fi

  printf 'Push directo falló. Intento crear upstream: origin/%s\n' "$branch" >&2
  git push -u origin "$branch"
}

# Lista ramas (locales y remotas) ordenadas por última actividad
br() {
  _req git || return 1
  _git_root_or_die || return 1

  git for-each-ref --sort=-committerdate \
    --format='%(refname:short)|%(committerdate:relative)|%(authorname)|%(subject)' refs/heads refs/remotes |
    column -t -s'|'
}
