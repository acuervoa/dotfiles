# docker.sh

# devuelve si tenemos "docker compose" o "docker-compose"
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
_docker_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

# Si estás en un repo git y en la raíz git existe docker-compose.yml o compose.yml,
# hace cd a esa raíz. Si no, no toca el cwd.
_cd_repo_root_if_compose() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local root
    root="$(git rev-parse --show-top-level 2>/dev/null)" || return 0

    if [ -f "$root/docker-compose.yml" ] || [ -f "$root/docker-compose.yaml" ]; then
      builtin cd -- "$root" || true
    fi
  fi
}

_list_running_services() {
  if out="$(_docker_compose ps --services --status=runnig 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  if out="$()_docker_compose ps --services --filter "status=running" 2>/dev/null)" && [ -n "$out" ]; then
    printf '%s\n' "$out"
    return 0
  fi

  return 1
}

# Servicios docker activos (docker compose ps)
# - Intenta situarte en la raíz del repo SOLO si ahí está el compose.
docps() {
  _req docker || return 1
  _have_compose || return 1

  _cd_repo_root_if_compose
  _docker_compose ps
}

# fzf para elegir servicio y ver logs en vivo
# - añadimos --tail 200 para no tragarnos todo el histórico.
dlogs() {
  _req fzf docker || return 1
  _have_compose || return 1

  _cd_repo_root_if_compose
  local svc
  svc="$(
    _docker_compose ps --services 2>/dev/null |
      fzf --prompt=' logs > ' --header='Selecciona servicio para tail -f'
  )" || return 0

  [ -z "$svc" ] && return 0

  _docker_compose logs --tail=200 -f "$svc"
}

# Abrir shell interactiva en un contenedor en ejecución
#
# - Sólo muestra servicios con contenedores "running".
# - Intenta bash, si no sh.
# - Si no hay contenedor corriendo, no te deja entrar.
dsh() {
  _req fzf docker || return 1
  _have_compose || return 1
  _cd_repo_root_if_compose

  local svc
  svc="$(
    _list_running_services |
      sort -u |
      fzf --prompt=' shell > ' --header='Servicios activos (running)'
  )" || return 0

  [ -z "$svc" ] && return 0

  _docker_compose exec "$svc" bash 2>/dev/null || _docker_compose exec "$svc" sh
}

# Limpiar recursos docker sin uso tras confirmación explícita
dclean() {
  _req docker || return 1

  printf '%s' 'Esto ejecutará "docker system prune" y eliminará contenedores detenidos, imágenes dangling y cachés. ¿Continuar? [y/N] ' >&2
  local ans
  read -r ans
  [ "$ans" = "y" ] || return 0

  docker system prune "$@"
}
