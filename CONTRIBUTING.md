# Contributing Guide

¡Gracias por contribuir! Este entorno busca **paridad de atajos**, **rendimiento** y **mantenibilidad**.

## Requisitos locales
- Linux (Arch/Debian/Fedora) o WSL2 + Bash.
- Herramientas: `git`, `bash`, `stow`, `fzf`, `ripgrep`, `tmux`, `neovim`.
- Dev helpers (opcionales pero recomendados): `shellcheck`, `shfmt`.

## Flujo de trabajo
1. Crea rama desde `main`:
   ```bash
   git checkout -b feat/<breve-descripcion>
   ```
2. Cambios mínimos y comentados. Mantén la **paridad de atajos** (i3 ↔ tmux ↔ (Neo)Vim ↔ kitty).
3. Ejecuta **checks** locales (ver abajo).
4. Añade/actualiza documentación si procede:
    - `CHANGELOG.md` (entrada con fecha y secciones Añadido/Cambiado/Corregido/Eliminado).
    - Docs ES: `README.md`, `README-BOOTSTRAP.md`.
    - Docs EN: `README.en.md`, `README-BOOTSTRAP.en.md`.
    - `SHORTCUTS.md` (si cambian bindings/atajos).
    - Este `CONTRIBUTING.md` si afecta al proceso.

5. Abre PR con descripción clara (qué y por qué).

## Estilo de commits
Preferimos [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/):
- `feat:`, `fix:`, `docs:`, `refactor:`, `perf:`, `chore:`, `style:`, `test:`
- Ejemplo: `feat(bash): añadir función fo con preview eza/bat`
- Referencia issues si aplica: `fixes #123`

## Calidad de código (shell)
- Sintaxis:
  ```bash
  bash -n ~/.bash_lib/*.sh
  ```
- Linter:
  ```bash
  shellcheck ~/.bash_lib/*.sh
  ```
- Formato (opcional):
  ```bash
  shfmt -w -i 2 ~/.bash_lib
  ```

## Validación funcional
- Recarga entorno y smoke tests:
  ```bash
  source ~/.bashrc
  type gbr gcof gclean gp watchdiff recent wip fixup | cat
  type docps dlogs dsh fo cdf take fhist bench envswap cb ports | cat
  bench sleep 0.1
  printf foo | cb && (command -v wl-paste >/dev/null && wl-paste || pbpaste)
  ```
- Navegación cruzada: `Ctrl+h/j/k/l` entre vim/tmux (plugin/vinculación).
- Docker compose: `docps` y `dlogs` deben funcionar con v1/v2.
- Pruebas manuales recomendadas:
  - `bash ./scripts/bootstrap.sh --dry-run` → revisar acciones.
  - `bash ./scripts/bootstrap.sh` → verificar symlinks creados y manifest en `.manifests/<TS>.manifest`.
  - Editar un dotfile enlazado (p.ej. `~/.bashrc`) y ejecutar `bash ./scripts/rollback.sh --manifest .manifests/<TS>.manifest`.
  - Probar `bash ./scripts/rollback.sh --dry-run latest` para validar que lista acciones sin tocar nada.

## Checklist de PR
- [ ] Cambios mínimos y compatibles con Arch estable.
- [ ] No introducir secretos (`{{REDACTED}}` si hay placeholders).
- [ ] `bash -n` sin errores, `shellcheck` limpio o justificado.
- [ ] Documentación actualizada (`CHANGELOG.md`, `README*.md`, `SHORTCUTS.md`).
- [ ] Paridad de atajos respetada; si cambia, documentado en `SHORTCUTS.md`.

## Publicación
- Merge `main` protegido. Después:
  - Actualiza `CHANGELOG.md`.
  - Tag opcional `YYYY.MM.DD-<scope>`.
