# Workflows de Neovim — editor general y backend

La configuración conserva `<leader> = espacio` y usa estos recorridos
principales. Las teclas descritas son las existentes en la configuración; no
se añaden mappings nuevos en esta fase.

## Editor general

1. Abrir proyecto y buscar archivos: `<C-p>` o `<leader>ff`.
2. Buscar texto: `<leader>fg`.
3. Cambiar de buffer: `<leader>bb`, `<leader>bp`, `<leader>bn`.
4. Navegar símbolos: `<leader>fs` o `<leader>cs` cuando hay LSP.
5. Revisar problemas: `<leader>xx` para workspace, `<leader>xd` para buffer.
6. Formatear: `<leader>cf`; controlar guardado automático con
   `:FormatToggle` o `:FormatToggleBuffer`.
7. Lint manual: `:Lint`.
8. Terminal: `<C-\`>` para ToggleTerm o `<leader>`` como fallback.

## Backend PHP/Laravel

1. Abrir el proyecto desde Bash/tmux y editar PHP; `lang/php.lua` mantiene la
   configuración de LSP, formato, lint, tests y DAP.
2. Usar `gd`, `K`, `<F2>`, `<leader>ca` y `<leader>cd` para navegación y
   acciones LSP cuando Intelephense esté disponible.
3. Ejecutar test cercano con `<leader>tt`, fichero con `<leader>tT` o proyecto
   con `<leader>ta` mediante `neotest-phpunit`.
4. Ejecutar tareas PHP/Laravel desde `<leader>or` y revisar resultados con
   `<leader>ot` mediante Overseer.
5. Formatear con `<leader>cf`; revisar el formatter efectivo con
   `:ConformInfo`.
6. Ejecutar `:Lint` para análisis manual y usar `<leader>xx` para el panel de
   diagnósticos.
7. Depurar Xdebug con `<F5>`, `<F9>`, `<leader>d0`, `<leader>dI`,
   `<leader>dU`, `<leader>du` y `<leader>dq` cuando el adaptador PHP esté
   instalado.

## Git y revisión

- Hunks: `]c`, `[c`, `<leader>hs`, `<leader>hr`, `<leader>hp`.
- Diff e histórico del repositorio: `<leader>hd`, `<leader>hD` y
  `<leader>gg` para LazyGit.
- El staging, commit y push siguen siendo responsabilidad del flujo Git de
  Bash; Neovim muestra y revisa cambios sin duplicar esas políticas.

## AI/Codex

- `<leader>ce`: explicar archivo.
- `<leader>cz`: explicar repositorio.
- `<leader>cD`: revisar diff.
- `<leader>cr`: proponer refactor.
- `<leader>cF`: proponer fix.
- `<leader>cv` en visual: explicar selección.

Los comandos de modificación se mantienen bajo control explícito del usuario.

## Degradación esperada

Si falta un binario externo, el mapping puede seguir existiendo pero la
capacidad mostrará el error propio del plugin o del comando. No se ejecutan
Docker, migraciones, tests del proyecto ni red durante las validaciones de
esta configuración.
