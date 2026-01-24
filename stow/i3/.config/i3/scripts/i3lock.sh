#!/usr/bin/env bash
set -euo pipefail

# i3lock.sh (X11)
# - Captura pantalla actual
# - Aplica pixelado ligero (rápido y consistente)
# - Lanza i3lock (i3lock-color si existe)

need_cmd() {
	command -v "$1" >/dev/null 2>&1
}

die() {
	printf '[i3lock] %s\n' "$*" >&2
	exit 1
}

# Requisitos mínimos
need_cmd i3lock || die "Falta i3lock"

# Dependencias opcionales (se usan en orden de preferencia)
# Captura: ffmpeg (x11grab) -> import -> scrot
# Procesado: magick/convert (ImageMagick)
capture_png=""
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

img="$tmpdir/lock.png"

# Detectar geometría
geom=""
if need_cmd xrandr; then
	# primera línea con modo actual
	geom="$(xrandr --current 2>/dev/null | awk '/\*/{print $1; exit}' || true)"
fi
# fallback: xdpyinfo
if [[ -z "${geom:-}" ]] && need_cmd xdpyinfo; then
	geom="$(xdpyinfo 2>/dev/null | awk -F'[ x]+' '/dimensions:/{print $3 "x" $4; exit}' || true)"
fi

# 1) Captura
if need_cmd ffmpeg; then
	# DISPLAY suele ser :0; x11grab necesita "DISPLAY+offset"
	disp="${DISPLAY:-:0}"
	if [[ -n "${geom:-}" ]]; then
		ffmpeg -loglevel error -y \
			-f x11grab -video_size "$geom" -i "${disp}.0" \
			-vframes 1 "$img" || true
	else
		ffmpeg -loglevel error -y \
			-f x11grab -i "${disp}.0" \
			-vframes 1 "$img" || true
	fi
fi

if [[ ! -s "$img" ]] && need_cmd import; then
	# ImageMagick import (X11)
	import -window root "$img" || true
fi

if [[ ! -s "$img" ]] && need_cmd scrot; then
	scrot -o "$img" || true
fi

[[ -s "$img" ]] || die "No se pudo capturar pantalla (instala ffmpeg o imagemagick o scrot)"

# 2) Procesado (pixelado rápido; evita blur caro en CPU)
# usa "magick" si existe; si no, "convert"
im_cmd=""
if need_cmd magick; then
	im_cmd="magick"
elif need_cmd convert; then
	im_cmd="convert"
fi

if [[ -n "$im_cmd" ]]; then
	# pixelate: downscale y upscale con nearest (rápido)
	# Ajusta el 10% si quieres más/menos pixelado
	"$im_cmd" "$img" -scale 10% -scale 1000% "$img" || true
fi

# 3) Lock (preferir i3lock-color si está disponible como i3lock)
# flags conservadores: no cambian comportamiento si no soportados
exec i3lock -i "$img"
