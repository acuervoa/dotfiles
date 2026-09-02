#!/usr/bin/env bash

set -u

if command -v mise >/dev/null 2>&1 && { [[ -f mise.toml ]] || [[ -f .mise.toml ]]; }; then
  if mise run logs-openresty 2>/dev/null; then
    exit 0
  fi
  if mise run logs-php 2>/dev/null; then
    exit 0
  fi
fi

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'No hay mise ni Docker disponibles para mostrar logs.'
  exit 0
fi

compose_file=''
log_service=''
if [[ -f .devroom.yml ]]; then
  config_value() {
    local key=$1 value
    value="$(awk -F: -v key="$key" \
      '$1 ~ "^[[:space:]]*" key "[[:space:]]*$" {sub(/^[^:]*:[[:space:]]*/, ""); print; exit}' \
      .devroom.yml)"
    value="${value%%#*}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    printf '%s' "$value"
  }

  compose_file="$(config_value compose_file)"
  log_service="$(config_value service)"
fi

if [[ -n "$compose_file" && ! -f "$compose_file" ]]; then
  printf 'Configuración .devroom.yml inválida: no existe %s.\n' "$compose_file"
  exit 0
fi

for candidate in \
  docker-compose.yml compose.yml compose.yaml \
  docker/docker-compose.yml docker/compose.yml docker/compose.yaml \
  infra/docker-compose.yml infra/compose.yml infra/compose.yaml \
  deploy/docker-compose.yml deploy/compose.yml deploy/compose.yaml \
  .docker/docker-compose.yml .docker/compose.yml .docker/compose.yaml; do
  [[ -n "$compose_file" ]] && break
  if [[ -f "$candidate" ]]; then
    compose_file="$candidate"
    break
  fi
done

if [[ -z "$compose_file" ]]; then
  printf '%s\n' 'No se encontró configuración de Docker Compose en este proyecto.'
  exit 0
fi

services="$(docker compose -f "$compose_file" config --services 2>/dev/null || true)"
if [[ -n "$log_service" ]] && ! grep -Fqx "$log_service" <<<"$services"; then
  printf 'Servicio %s no existe en %s. Servicios: %s\n' \
    "$log_service" "$compose_file" "${services//$'\n'/, }"
  exit 0
fi

if [[ -z "$log_service" ]]; then
  for service in openresty php php-nginx api app backend web; do
    if grep -Fqx "$service" <<<"$services"; then
      log_service="$service"
      break
    fi
  done
fi

if [[ -n "$log_service" ]]; then
  service="$log_service"
  if grep -Fqx "$service" <<<"$services"; then
    container_ids="$(docker compose -f "$compose_file" ps -q "$service" 2>/dev/null || true)"
    if [[ -z "$container_ids" ]]; then
      printf 'Servicio %s definido en %s, pero no está levantado. Arráncalo con: docker compose -f %s up -d %s\n' \
        "$service" "$compose_file" "$compose_file" "$service"
      exit 0
    fi
    exec docker compose -f "$compose_file" logs -f "$service"
  fi
fi

printf 'Compose detectado en %s, pero no hay servicio de logs conocido. Servicios: %s\n' \
  "$compose_file" "${services//$'\n'/, }"
