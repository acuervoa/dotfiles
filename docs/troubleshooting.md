# Troubleshooting

Errores comunes y soluciones rapidas.

## Neovim: theme/plugin faltante

- Ejecuta `:Lazy sync` y reinicia Neovim.
- Revisa `:Mason` y `:CheckHealth` para dependencias externas.

## Conflictos de stow

- Corre `bash ./scripts/bootstrap.sh --dry-run` para ver conflictos.
- Revisa `scripts/doctor.sh` (conflicts + lint) antes de aplicar.

## Faltan dependencias

- Ejecuta `bash ./scripts/doctor.sh` y luego `bash ./scripts/install_deps.sh --core`.
- En desktop, agrega `--gui`.

## Secrets scan marca falsos positivos

- Revisa el match con numero de linea.
- Ajusta patrones si es necesario o usa archivos `_local` para secretos.
