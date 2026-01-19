# ~/.bash_lib/docker.sh
# docker.sh - helpers para docker compose

# shellcheck shell=bash

# @cmd _have_compose  Comprobar si existe docker compose (v1 o v2)
_have_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    return 0
  fi
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    return 0
  fi

  printf 'No encuentro ni "docker-compose" ni "docker compose".\n' >&2
  return 1
}

# @cmd _docker_compose  Wrapper unificado sobre docker-compose/docker compose
_docker_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

# @cmd _cd_repo_root_if_compose  Subir hasta el directorio que tenga el docker-compose.yml/compose.yml
_cd_repo_root_if_compose() {
  local dir="$PWD"

  while :; do
    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ] ||
      [ -f "$dir/compose.yml" ] || [ -f "$dir/compose.yaml" ]; then
      cd -- "$dir" || return 1
      return 0
    fi

    if [ "$dir" = "/" ]; then
      printf 'No se ha encontrado docker-compose.yml/compose.yml al subir desde %s.\n' "$PWD" >&2
      return 1
    fi

    dir="$(dirname "$dir")"
  done
}

# @cmd _list_running_services  Listar servicios con contenedores en ejecución (o todos como fallback)
_list_running_services() {
  local out

  # Primero, sólo running
  if out="$(_docker_compose ps --services --status=running 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  # Si no hay running, probamos todos
  if out="$(_docker_compose ps --services 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  printf 'No se han encontrado servicios de docker compose en el proyecto actual.\n' >&2
  return 1
}

# Servicios docker activos (docker compose ps)
# - Intenta situarte en la raíz del repo SOLO si ahí está el compose.
# @cmd docps  docker compose ps normalizado
docps() {
  _have_compose || return 1
  _cd_repo_root_if_compose || return 1
  _docker_compose ps "$@"
}

# Rebuild rápido (build + up -d) sin cache
# @cmd dorebuild  docker compose build --no-cache + up -d
dorebuild() {
  _have_compose || return 1
  _cd_repo_root_if_compose || return 1
  _docker_compose build --no-cache "$@" && _docker_compose up -d
}

# fzf para elegir servicio y ver logs en vivo
# - añadimos --tail 200 para no tragarnos todo el histórico.
# @cmd dlogs  Tail -f de logs de un servicio (fzf si no se pasa nombre)
dlogs() {
  _req fzf || return 1
  _have_compose || return 1
  _cd_repo_root_if_compose || return 1

  local svc="${1:-}"

  if [ -z "$svc" ]; then
    local services
    if ! services="$(_list_running_services)"; then
      return 1
    fi

    svc="$(printf '%s\n' "$services" | fzf --prompt=' service > ')" || return 0
  fi

  [ -z "$svc" ] && return 0

  _docker_compose logs --tail=200 -f "$svc"
}

# Abrir shell interactiva en un contenedor en ejecución
#
# - Sólo muestra servicios con contenedores "running".
# - Intenta bash, si no sh.
# - Si no hay contenedor corriendo, no te deja entrar.
# @cmd dsh  Entrar en shell de un contenedor de servicio (bash/sh)
dsh() {
  _req fzf || return 1
  _have_compose || return 1
  _cd_repo_root_if_compose || return 1

  local svc="${1:-}"

  if [ -z "$svc" ]; then
    local services
    if ! services="$(_list_running_services)"; then
      return 1
    fi

    svc="$(
      printf '%s\n' "$services" |
        fzf --prompt=' dsh > ' --header='Selecciona servicio para abrir shell'
    )" || return 0
  fi

  [ -z "$svc" ] && return 0

  # Soporta override de shell: DSH_SHELL=bash|sh
  local shell="${DSH_SHELL:-bash}"
  _docker_compose exec "$svc" "$shell" 2>/dev/null || _docker_compose exec "$svc" sh
}

# Limpiar recursos docker sin uso tras confirmación explícita
# @cmd dclean  docker system prune con confirmación
dclean() {
  _req docker || return 1

  printf 'Se eliminarán contenedores detenidos, imágenes dangling y cachés.\n' >&2
  if ! _confirm '¿Continuar? [y/N] '; then
    return 0
  fi

  printf 'Ejecutando docker system prune\n\n' >&2
  docker system prune "$@" --force
}
