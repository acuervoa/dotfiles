_docker_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    docker compose "$@"
  fi
}

# Servicios docker activos (docker compose ps)
docps() {
  _req docker || return 1
  (grt >/dev/null 2>&1 || true)
  _docker_compose ps
}

# fzf para elegir servicio y ver logs -f
dlogs() {
  _req fzf docker || return 1
  (grt >/dev/null 2>&1 || true)

  local svc
  svc="$(
    if command -v docker-compose >/dev/null 2>&1; then
      docker-compose ps --services
    else
      docker compose ps --services
    fi | fzf --prompt=' logs > '
  )" || return 0

  [ -z "$svc" ] && return 0

  _docker_compose logs -f "$svc"
}

# Entrar en un servicio con /bin/sh (o bash si existe)
dsh() {
  _req fzf docker || return 1
  (grt >/dev/null 2>&1 || true)

  local svc
  svc="$(
    if command -v docker-compose >/dev/null 2>&1; then
      docker-compose ps --services
    else
      docker compose ps --services
    fi | fzf --prompt=' shell > '
  )" || return 0

  [ -z "$svc" ] && return 0

  _docker_compose exec "$svc" bash 2>/dev/null || _docker_compose exec "$svc" sh
}
