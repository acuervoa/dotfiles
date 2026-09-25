# misc.sh - utilidades varias
# shellcheck shell=bash

# buscar en historial con fzf y (opcionalmente) ejecutar
# - Si no hay historial disponible, aborta limpio.
# - Dedup: colapsa comandos idénticos para no ver 40 veces el mismo curl.
# - Preview para ver el comando completo.
# - Ejecuta en SUBSHELL ( ) para no ensuciar sesión actual a no ser que confirmes --live.
#
# Uso:
#   fhist           -> busca, pregunta, ejecuta en subshell si dices "y"
#   fhist --live    -> ejecuta en shell (eval) si dices "y"
# @cmd fhist  Buscar en history con fzf y ejecutar (subshell o live)
fhist() {
  _req fzf || return 1

  local mode="subshell"
  if [ "$1" = "--live" ]; then
    mode="live"
    shift
  fi

  local hist
  hist="$(HISTTIMEFORMAT='' history 2>/dev/null | sed 's/^ *[0-9]\+ *//')" || true
  if [ -z "$hist" ]; then
    printf 'No hay historial disponible en esta sesión.\n' >&2
    return 1
  fi

  hist="$(
    printf '%s\n' "$hist" |
      tac | awk '!seen[$0]++' | tac |
      grep -Ev '^(ls|cd|pwd|historyi|fhist|redo|r)($| )' || true
  )"

  if [ -z "$hist" ]; then
    printf 'No hay comandos interesantes tras el filtrado.\n' >&2
    return 1
  fi

  local cmd
  cmd="$(
    printf '%s\n' "$hist" |
      fzf --tac \
        --prompt='📜 hist > ' \
        --preview='echo {}' \
        --preview-window=down,3
  )" || return 0

  [ -z "$cmd" ] && return 0

  printf 'Comando seleccionado:\n%s\n' "$cmd" >&2
  if ! _confirm '¿Ejecutar ahora? [y/N] '; then
    printf '%s\n' "$cmd"
    return 0
  fi

  case "$mode" in
  live) eval "$cmd" ;;
  subshell) (eval "$cmd") ;;
  esac
}

# lista/añade tareas rápidas en ~/.todo.cli.txt
# - Evita crear el archivo con permisos abiertos. Lo fuerza a 600.
# @cmd todo   Añadir entrada a un TODO plano con timestamp
todo() {
  local file="${TODO_FILE:-$HOME/.todo.cli.txt}"
  mkdir -p -- "$(dirname "$file")" 2>/dev/null || true

  if [ ! -f "$file" ]; then
    : >"$file"
    chmod 600 "$file" 2>/dev/null || true
  fi

  if [ $# -eq 0 ]; then
    nl -ba "$file" 2>/dev/null || printf 'Lista vacía.\n'
    return 0
  fi

  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M')" "$*" >>"$file"
  printf "Añadido a TODO: %s\n" "$*" >&2
}

# Mide cuanto tiempo tarda en ejecutarse un comandos
# # - Ejecuta el comando en SUBSHELL para no alterar la sesión.
# @cmd bench  Medir el tiempo de ejecución de un comando (ms/segundos)
bench() {
  _req awk || return 1

  if [ $# -eq 0 ]; then
    printf 'Uso: bench <comando ...>\n' >&2
    return 1
  fi

  _now_ms() {
    if date +%s%3N >/dev/null 2>&1; then
      date +%s%3N
      return
    fi

    date +%s | awk '{ print $1 * 1000 }'
  }

  local start end delta
  start="$(_now_ms)"
  ("$@")
  local status=$?
  end="$(_now_ms)"

  delta=$((end - start))

  if command -v bc >/dev/null 2>&1; then
    printf 'Tiempo: %s ms (~%.3f s)\n' "$delta" \
      "$(printf '%s / 1000' "$delta" | bc -l)"
  else
    printf 'Tiempo: %s ms (~%s s)\n' "$delta" "$((delta / 1000))"
  fi

  return "$status"
}

# Cambia entre distintos .env de forma segura
# uso:
#   envswap list
#   envswap use staging
#
# - asume archivos tipo .env.staging, .env.local, etc.
# - Valida que exista .env.* antes de tocar nada.
# - Hace backup con permisos 600.
# - Fuerza permisos 600 en el .env final.
# @cmd envswap  Gestionar .env.<nombre> -> .env con backup (permiso 600)
envswap() {
  local base=".env"
  local cmd="${1:-}"
  local name="${2:-}"

  if [ "$cmd" = "list" ]; then
    local f
    local -a envs=()

    for f in .env.*; do
      # si no hay coincidencias, el glob se queda literal
      [ -e "$f" ] || continue
      envs+=("${f#.env.}")
    done

    # Nada que listar
    ((${#envs[@]} == 0)) && return 0

    # Ordenado
    printf '%s\n' "${envs[@]}" | sort
    return 0
  fi

  if [ "$cmd" = "use" ] && [ -n "$name" ]; then
    local src=".env.$name"

    if [ ! -f "$src" ]; then
      printf 'No existe %s\n' "$src" >&2
      return 1
    fi

    printf 'Se activará %s sobre %s.\n' "$src" "$base" >&2
    _confirm '¿Continuar? [y/N] ' || return 0

    if [ -f "$base" ]; then
      local bak stamp suffix
      stamp="$(date +%Y%m%d-%H%M%S)"
      suffix=0
      while :; do
        bak="$base.bak.$stamp.$$.$suffix"
        [ ! -e "$bak" ] && break
        suffix=$((suffix + 1))
      done
      cp -- "$base" "$bak" || {
        printf 'No se pudo crear el backup %s\n' "$bak" >&2
        return 1
      }
      chmod 600 "$bak" 2>/dev/null || true
      printf '(backup en %s)\n' "$bak" >&2
    fi

    cp -- "$src" "$base" || {
      printf 'No se pudo activar %s\n' "$src" >&2
      return 1
    }
    chmod 600 "$base" 2>/dev/null || true
    printf '✔ %s activado -> %s\n' "$src" "$base" >&2
    return 0
  fi

  printf 'Uso:\n' >&2
  printf '  envswap list           # ver entornos disponibles (.env.*)\n' >&2
  printf '  envswap use staging    # copia .env.staging -> .env (con backup y chmod 600)\n' >&2
  return 1
}

# Quien escucha en que puerto
# @cmd ports  Ver puertos en escucha (ss/netstat simplificado)
ports() {
  _req awk || return 1

  if command -v ss >/dev/null 2>&1; then
    ss -tulpen 2>/dev/null |
      awk '
        NR==1 {
          printf "%-6s %-30s %-24s %-10s\n", "Proto","Local","PID/Program","User"
          next
        }
        {
          proto=$1;
          laddr=$5;
          user=$6;
          prog=$7;
          printf "%-6s %-30s %-24s %-10s\n", proto, laddr, prog, user
        }
      '
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tulpen 2>/dev/null |
      awk '
        NR==1 {
          printf "%-6s %-30s %-24s %-10s\n", "Proto","Local","PID/Program","User"
          next
        }
        {
          proto=$1;
          laddr=$5;
          user=$6;
          prog=$7;
          printf "%-6s %-30s %-24s %-10s\n", proto, laddr, prog, user
        }
      '
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN
  else
    printf 'Necesito ss, netstat o lsof.\n' >&2
    return 1
  fi
}

# editar y re-ejecutar el último comando del history
#
# - Usa penúltima entrada del history (evita capturar el propio 'r').
# - Crea tmp 600.
# - Después de ejecutar, borra el tmp.
# - Pregunta antes de ejecutar con `source`
# @cmd r  Editar y re-ejecutar el penúltimo comando del history
r() {
  # Nos aseguramos que hay editor
  if ! _req "${VISUAL:-${EDITOR:-nvim}}"; then
    printf 'No encuentro editor (VISUAL/EDITOR/nvim).\n' >&2
    return 1
  fi

  local tmp last
  tmp="$(mktemp)"
  chmod 600 "$tmp" 2>/dev/null || true

  last="$(
    HISTTIMEFORMAT='' history 2>/dev/null |
      sed 's/^ *[0-9]\+ *//' |
      tail -n 2 | head -n 1
  )"

  if [ -z "$last" ]; then
    printf 'No puedo recuperar el último comando.\n' >&2
    rm -f -- "$tmp"
    return 1
  fi

  printf '%s\n' "$last" >"$tmp"
  "${VISUAL:-${EDITOR:-nvim}}" "$tmp"

  printf 'Esto se va a ejecutar en la shell actual.\n' >&2
  if ! _confirm '¿Ejecutar? [y/N] '; then
    rm -f -- "$tmp"
    return 0
  fi

  # shellcheck disable=SC1090
  . "$tmp"
  rm -f -- "$tmp"
}

# Añade un temporizador interactivo simple
# @cmd tt   Temporizador manual (ENTER para parar)
tt() {
  local start end delta
  start=$(date +%s)
  printf 'Timer iniciado. Pulsa ENTER al terminar...\n' >&2
  read -r _
  end=$(date +%s)
  delta=$((end - start))
  printf '%s segundos (%s min)\n' "$delta" "$((delta / 60))"
}

# Monitoreo rapido de CPU/MEM de procesos que me importan
# Prioriza por CPU alta
# @cmd topme  Procesos relevantes (stack dev) ordenados por consumo
topme() {
  _req awk ps || return 1
  ps -eo pid,ppid,user,%cpu,%mem,etime,cmd --sort=-%cpu |
    awk 'NR==1 || /php|fpm|nginx|mysql|maria|docker|composer|artisan|symfony|node|redis|postg|psql/'
}

# Wrapper de Yazi, cd al salir
# @cmd y  Wrapper de yazi que hace cd al salir
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"

  if ! IFS= read -r -d '' cwd <"$tmp"; then
    cwd="$(cat -- "$tmp")"
  fi

  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || printf 'y: no pude hacer cd a "%s"\n' "$cwd" >&2
  fi

  rm -f -- "$tmp"
}

# @cmd dev  Crear/adjuntar sesión tmux ligada al proyecto actual (layout estándar en paneles)
dev() {
    _req tmux || return 1

    local dest name editor_cmd logs_cmd
    local editor_pane agent_pane logs_pane shell_pane

    # ---------------------------------------------------------------
    # Resolve project
    # ---------------------------------------------------------------

    if [ -n "${1:-}" ]; then
        if [ -d "$1" ]; then
            dest="$(cd -- "$1" && pwd)"
        else
            printf 'dev: directorio no existe: %s\n' "$1" >&2
            return 1
        fi
    else
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            dest="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
        else
            if ! command -v proj >/dev/null 2>&1; then
                printf 'dev: proj no está definido y no estás en un repo git.\n' >&2
                return 1
            fi

            local prev_pwd="$PWD"

            dest="$(
                cd -- "$prev_pwd" || exit 1
                proj || exit 1
                pwd
            )" || {
                printf 'dev: selección de proyecto cancelada.\n' >&2
                return 1
            }

            if [ "$dest" = "$prev_pwd" ]; then
                printf 'dev: no se ha seleccionado ningún proyecto.\n' >&2
                return 1
            fi
        fi
    fi

    if [ -z "$dest" ] || [ ! -d "$dest" ]; then
        printf 'dev: destino inválido: %s\n' "${dest:-<vacío>}" >&2
        return 1
    fi

    name="$(basename "$dest")"

    # ---------------------------------------------------------------
    # Existing workspace
    # ---------------------------------------------------------------

    if tmux has-session -t "=${name}" 2>/dev/null; then
        if [ -n "${TMUX:-}" ]; then
            tmux switch-client -t "$name"
        else
            tmux attach -t "$name"
        fi

        return 0
    fi

    # ---------------------------------------------------------------
    # Resolve editor
    # ---------------------------------------------------------------

    if [ -n "${VISUAL:-}" ]; then
        editor_cmd="$VISUAL"
    elif [ -n "${EDITOR:-}" ]; then
        editor_cmd="$EDITOR"
    elif command -v nvim >/dev/null 2>&1; then
        editor_cmd="nvim"
    elif command -v vim >/dev/null 2>&1; then
        editor_cmd="vim"
    else
        editor_cmd="nano"
    fi

    editor_cmd="${editor_cmd} ."
    logs_cmd="$HOME/.tmux/scripts/project_logs.sh"

    # ---------------------------------------------------------------
    # Window 1: dev / editor
    # ---------------------------------------------------------------

    tmux new-session \
        -d \
        -s "$name" \
        -c "$dest" \
        -n dev

    editor_pane="$(
        tmux display-message \
            -p \
            -t "$name:dev" \
            '#{pane_id}'
    )"

    tmux select-pane \
        -t "$editor_pane" \
        -T "EDITOR"

    # ---------------------------------------------------------------
    # Window 2: agent
    #
    # Deliberately starts as a plain shell.
    # Agent lifecycle remains manual for now.
    # ---------------------------------------------------------------

    agent_pane="$(
        tmux new-window \
            -d \
            -P \
            -F '#{pane_id}' \
            -t "${name}:" \
            -n agent \
            -c "$dest"
    )"

    tmux select-pane \
        -t "$agent_pane" \
        -T "AGENT"

    # ---------------------------------------------------------------
    # Window 3: runtime
    # ---------------------------------------------------------------

    logs_pane="$(
        tmux new-window \
            -d \
            -P \
            -F '#{pane_id}' \
            -t "${name}:" \
            -n runtime \
            -c "$dest"
    )"

    shell_pane="$(
        tmux split-window \
            -d \
            -v \
            -P \
            -F '#{pane_id}' \
            -t "$logs_pane" \
            -c "$dest"
    )"

    tmux select-pane \
        -t "$logs_pane" \
        -T "LOGS"

    tmux select-pane \
        -t "$shell_pane" \
        -T "SHELL"

    tmux set-window-option \
        -t "$name:runtime" \
        pane-border-status top

    tmux set-window-option \
        -t "$name:runtime" \
        allow-rename off

    tmux set-window-option \
        -t "$name:runtime" \
        pane-border-format \
        ' #[fg=#cba6f7,bold]#P #{pane_title}#[default] '

    # ---------------------------------------------------------------
    # Start controlled commands
    # ---------------------------------------------------------------

    if [ -x "$logs_cmd" ]; then
        tmux send-keys \
            -t "$logs_pane" \
            "$logs_cmd" \
            C-m
    else
        printf 'dev: aviso: logs script no ejecutable: %s\n' "$logs_cmd" >&2
    fi

    tmux send-keys \
        -t "$editor_pane" \
        "$editor_cmd" \
        C-m

    # Start focused on editor.
    tmux select-window -t "$name:dev"

    # ---------------------------------------------------------------
    # Attach / switch
    # ---------------------------------------------------------------

    if [ -n "${TMUX:-}" ]; then
        tmux switch-client -t "$name"
    else
        tmux attach -t "$name"
    fi
}

tswitch() {
  _req tmux fzf || return 1
  [ -z "${TMUX:-}" ] && {
    printf 'tswitch: no estás dentro de tmux.\n' >&2
    return 1
  }

  local current target

  current="$(tmux display-message -p '#S')"

  target="$(
    tmux list-sessions -F '#S' |
      grep -v "^${current}$" |
      fzf --prompt=' tmux session > '
  )" || return 0

  [ -z "$target" ] && return 0

  # Cambiamos el Destino
  tmux switch-client -t "$target"

  # Matamos la sesión anteriorf sólo si sigue existiendo
  if tmux has-session -t "$current" 2>/dev/null; then
    tmux kill-session -t "$current"
  fi
}

# @cmd qa  Ejecutar pruebas/QA del proyecto actual (prefiere mise, luego heurística PHP)
qa() {
  # 1) Preferir tareas de mise (qa > test)
  if command -v mise >/dev/null 2>&1; then
    # Listamos tareas una vez
    local tasks
    tasks="$(mise tasks ls --no-header 2>/dev/null | awk '{print $1}')" || tasks=""

    if printf '%s\n' "$tasks" | grep -qx 'qa'; then
      mise run qa "$@"
      return $?
    fi

    if printf '%s\n' "$tasks" | grep -qx 'test'; then
      mise run test "$@"
      return $?
    fi
  fi

  # 2) Heurística PHP: composer + phpunit
  if [ -f composer.json ]; then
    # Con docker compose y servicio php
    if command -v docker >/dev/null 2>&1 && docker compose config >/dev/null 2>&1; then
      if docker compose ps php >/dev/null 2>&1; then
        docker compose exec php php vendor/bin/phpunit "$@"
        return $?
      fi
    fi

    # Sin docker: phpunit local
    if [ -x vendor/bin/phpunit ]; then
      php vendor/bin/phpunit "$@"
      return $?
    fi

    printf 'qa: composer.json detectado pero no encuentro phpunit (ni docker php, ni vendor/bin/phpunit).\n' >&2
    return 1
  fi

  printf 'qa: no hay tareas de mise (qa/test) ni heurística conocida para este proyecto.\n' >&2
  printf '    Define una tarea [tasks.qa] o [tasks.test] en mise.toml.\n' >&2
  return 1
}

# @cmd rtest  Ejecutar tests del proyecto actual según stack (mise/composer/npm/etc)
rtest() {
  local root cmd=""

  # Si estamos en repo git, vamos a la raíz
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    cd -- "$root" || {
      printf 'rtest: no puedo hacer cd a %s\n' "$root" >&2
      return 1
    }
  fi

  # 1) mise: tarea "test"
  if command -v mise >/dev/null 2>&1 && [ -f "mise.toml" ]; then
    cmd="mise run test"

  # 2) composer: asumimos script "test"
  elif [ -f "composer.json" ] && command -v composer >/dev/null 2>&1; then
    cmd="composer test"

  # 3) Node: pnpm > npm > yarn
  elif [ -f "package.json" ]; then
    if command -v pnpm >/dev/null 2>&1; then
      cmd="pnpm test"
    elif command -v npm >/dev/null 2>&1; then
      cmd="npm test"
    elif command -v yarn >/dev/null 2>&1; then
      cmd="yarn test"
    fi

  # 4) PHPUnit standalone
  elif [ -x "vendor/bin/phpunit" ]; then
    cmd="vendor/bin/phpunit"

  # 5) Makefile: target test
  elif [ -f "Makefile" ] && command -v make >/dev/null 2>&1; then
    cmd="make test"
  fi

  if [ -z "$cmd" ]; then
    printf 'rtest: no sé qué comando de tests usar en %s\n' "${root:-$PWD}" >&2
    printf '  Define una tarea \"test\" (mise/composer/npm) o un target \"test\" en Makefile.\n' >&2
    return 1
  fi

  printf 'rtest: ejecutando %s\n' "$cmd" >&2
  eval "$cmd"
}

# @cmd rserve  Arrancar servidor/dev del proyecto actual (mise/npm/composer/docker)
rserve() {
  local root cmd=""

  # Ir a la raíz del repo si hay Git
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    cd -- "$root" || {
      printf 'rserve: no puedo hacer cd a %s\n' "$root" >&2
      return 1
    }
  fi

  # --- Preferencia 1: mise.toml (dev > up) ---
  if command -v mise >/dev/null 2>&1 && [ -f "mise.toml" ]; then
    # Listamos tareas una vez
    local tasks
    tasks="$(mise tasks 2>/dev/null | awk '{print $1}')" || tasks=""

    if printf '%s\n' "$tasks" | grep -qx "dev"; then
      cmd="mise run dev"
    elif printf '%s\n' "$tasks" | grep -qx "up"; then
      cmd="mise run up"
    fi
  fi

  # --- Preferencia 2: Node (dev) ---
  if [ -z "$cmd" ] && [ -f "package.json" ]; then
    if command -v pnpm >/dev/null 2>&1; then
      cmd="pnpm dev"
    elif command -v npm >/dev/null 2>&1; then
      cmd="npm run dev"
    elif command -v yarn >/dev/null 2>&1; then
      cmd="yarn dev"
    fi
  fi

  # --- Preferencia 3: Symfony CLI ---
  if [ -z "$cmd" ] && [ -f "composer.json" ] && command -v symfony >/dev/null 2>&1; then
    cmd="symfony serve"
  fi

  # --- Preferencia 4: docker compose directo ---
  if [ -z "$cmd" ] && { [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] ||
    [ -f "compose.yml" ] || [ -f "compose.yaml" ]; }; then
    if command -v docker-compose >/dev/null 2>&1; then
      cmd="docker-compose up"
    elif command -v docker >/dev/null 2>&1; then
      cmd="docker compose up"
    fi
  fi

  if [ -z "$cmd" ]; then
    printf 'rserve: no sé qué comando de servidor usar en %s\n' "${root:-$PWD}" >&2
    printf '  Define una tarea \"dev\" o \"up\" en mise, o un comando \"dev\" en package.json,\n' >&2
    printf '  o un compose.yml.\n' >&2
    return 1
  fi

  printf 'rserve: ejecutando %s\n' "$cmd" >&2
  eval "$cmd"
}

# @cmd rqa  Ejecutar pipeline de calidad del proyecto actual (mise qa, si existe)
rqa() {
  local root cmd=""

  # Ir a raíz del repo si hay Git
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    cd -- "$root" || {
      printf 'rqa: no puedo hacer cd a %s\n' "$root" >&2
      return 1
    }
  fi

  # 1) mise: tarea qa
  if command -v mise >/dev/null 2>&1 && [ -f "mise.toml" ]; then
    local tasks
    tasks="$(mise tasks 2>/dev/null | awk '{print $1}')" || tasks=""
    if printf '%s\n' "$tasks" | grep -qx "qa"; then
      cmd="mise run qa"
    fi
  fi

  # 2) Fallback: rtest
  if [ -z "$cmd" ]; then
    cmd="rtest"
  fi

  printf 'rqa: ejecutando %s\n' "$cmd" >&2
  eval "$cmd"
}
