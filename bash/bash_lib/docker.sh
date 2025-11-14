# docker.sh - helpers para docker compose

# devuelve si tenemos "docker compose" o "docker-compose"
# @cmd _have_compose  Comprobar si existe docker compose (v1 o v2)
_have_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    return 0
  fi
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    return 0
  fi

  printf 'No encuentro ni "docker-compose" ni "docker compose". \n' >&2
  return 1
}

# wrapper que llama a 'docker-compose' (v1) o 'docker compose' (v2 plugin)
# @cmd _docker_compose  Wrapper unificado sobre docker-compose/docker compose
_docker_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

# Si estás en un repo git y en la raíz git existe docker-compose.yml o compose.yml,
# hace cd a esa raíz. Si no, no toca el cwd.
# @cmd _cd_repo_root_if_compose   Subir hasta el directorio qeu tenga el docker-compose.yml/compose.yml
_cd_repo_root_if_compose() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ] ||
      [ -f "$dir/compose.yml" ] || [ -f "$dir/compose.yaml" ]; then
      cd "$dir" || return 1
      return 0
    fi
    dir="${dir%/*}"
  done
  return 0
}

# @cmd _list_running_services   Listar servicios con contenedores en ejecución (o todos como fallback)
_list_running_services() {
  local out

  if out="$(_docker_compose ps --services --status=running 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  if out="$(_docker_compose ps --services 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  return 1
}

# Servicios docker activos (docker compose ps)
# - Intenta situarte en la raíz del repo SOLO si ahí está el compose.
# @cmd docps  docker compose ps normalizado
docps() {
  _req docker || return 1
  _have_compose || return 1

  _cd_repo_root_if_compose
  _docker_compose ps "$@"
}

# fzf para elegir servicio y ver logs en vivo
# - añadimos --tail 200 para no tragarnos todo el histórico.
# @cmd dlogs  Tail -f de logs de un servicio (fzf si no se pasa nombre)
dlogs() {
  _req fzf docker || return 1
  _have_compose || return 1
  _cd_repo_root_if_compose

  local svc="${1:-}"
  if [ -z "$svc" ]; then
    svc="$(__list_running_services | fzf --prompt=' service > ')" || return 0
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
  _req fzf docker || return 1
  _have_compose || return 1
  _cd_repo_root_if_compose

  local svc="${1:-}"

  if [ -z "$svc" ]; then
    svc="$(
      _list_running_services 2>/dev/null |
        fzf --prompt=' dsh > ' --header='Selecciona servicio para abrir shell'
    )" || return 0
  fi

  [ -z "$svc" ] && return 0

  _docker_compose exec "$svc" bash 2>/dev/null || _docker_compose exec "$svc" sh
}

# Limpiar recursos docker sin uso tras confirmación explícita
# @cmd dclean   docker system prune con confirmación
dclean() {
  _req docker || return 1
  _confirm 'Se eliminaran contenedores detenidos, imágenes dangling y cachés. ¿Continuar? [y/N] ' || return 0
  printf 'Ejecutando docker system prune\n\n'
  docker system prune "$@" --force
}
