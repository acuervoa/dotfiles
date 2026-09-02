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
for candidate in \
  docker-compose.yml compose.yml compose.yaml \
  docker/docker-compose.yml docker/compose.yml docker/compose.yaml; do
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
for service in openresty php php-nginx; do
  if grep -Fqx "$service" <<<"$services"; then
    container_ids="$(docker compose -f "$compose_file" ps -q "$service" 2>/dev/null || true)"
    if [[ -z "$container_ids" ]]; then
      printf 'Servicio %s definido en %s, pero no está levantado. Arráncalo con: docker compose -f %s up -d %s\n' \
        "$service" "$compose_file" "$compose_file" "$service"
      exit 0
    fi
    exec docker compose -f "$compose_file" logs -f "$service"
  fi
done

printf 'Compose detectado en %s, pero no hay servicio de logs conocido. Servicios: %s\n' \
  "$compose_file" "${services//$'\n'/, }"
