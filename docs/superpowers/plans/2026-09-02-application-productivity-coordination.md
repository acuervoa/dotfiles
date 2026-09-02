# Application Productivity Coordination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Coordinar los aplicativos ya instalados alrededor de owners únicos y workflows repetibles, reforzando la memoria muscular entre Bash, ble.sh, tmux, i3, Kitty y Neovim sin añadir atajos innecesarios.

**Architecture:** i3 será el owner de aplicaciones y ventanas; Kitty, del transporte terminal; tmux, de panes, ventanas y sesiones; Bash/ble.sh, de la interacción textual y comandos de proyecto; Neovim, del código; Rofi, de selección visual; Dunst/Polybar, del feedback y estado. Cada capacidad tendrá un único owner y las integraciones usarán contratos existentes (`C-s`, `$mod`, `C-r`, `C-t`, `M-c`, `<leader>a*`, `<leader>p*`).

**Tech Stack:** Bash 5.3, ble.sh, Atuin, FZF, Rofi, Kitty, tmux, i3, Polybar, Dunst, CopyQ, zoxide, direnv, Starship, mise, fnm, Neovim 0.12, LazyGit, Yazi, lnav y scripts de validación del repositorio.

---

## Reglas de alcance

- No leer ni modificar `~/.bashrc_local`.
- No cambiar tmux o i3 salvo que un test o una regresión demostrable lo exija.
- No eliminar aliases ni bindings existentes en esta iteración; cualquier alias nuevo será compatibilidad y tendrá owner documentado.
- No introducir un segundo historial, prompt, launcher, clipboard manager o multiplexor.
- Cada bloque tendrá: test rojo, implementación mínima, test verde, documentación y commit independiente.
- Las pruebas manuales se reservan para la fase final de uso; el trabajo previo debe ser automatizable.

## Mapa de archivos y responsabilidades

- `stow/bash/.bashrc`: orden de inicialización de ble.sh, Atuin, FZF, Starship, mise, fnm y direnv.
- `stow/bash/.bash_lib/keymap.sh`: owner de bindings interactivos Bash/ble.sh.
- `stow/blesh/.config/blesh/blerc`, `stow/blesh/.blerc`: configuración específica de ble.sh; consolidar el punto de carga antes de añadir opciones.
- `stow/i3/.config/i3/config`: aplicaciones, ventanas, Rofi, scratchpads y workspaces.
- `stow/i3/.config/i3/scripts/`: acciones gráficas invocadas por i3.
- `stow/kitty/.config/kitty/kitty.conf`: terminal, transporte de teclas, clipboard y apariencia.
- `stow/tmux/.tmux.conf`, `stow/tmux/.tmux/scripts/`: panes, ventanas, sesiones, status y clipboard desde tmux.
- `stow/rofi/.config/rofi/config.rasi`: estilo y defaults de selección visual.
- `stow/copyq/.config/copyq/`: historial visual de clipboard.
- `stow/polybar/.config/polybar/config.ini`: estado persistente de i3 y sistema.
- `stow/dunst/.config/dunst/dunstrc`, `stow/dunst/.config/dunst/mocha.conf`: feedback no modal.
- `stow/nvim/.config/nvim/`: código, Git, AI y workflows de proyecto.
- `stow/lazygit/.config/lazygit/config.yml`: interfaz Git compartida.
- `stow/yazi/.config/yazi/`: navegación de filesystem desde Bash.
- `stow/lnav/` y scripts Bash/tmux: observabilidad de logs.
- `tests/`: contratos estáticos, headless, idempotencia y ausencia de colisiones.
- `docs/audits/`: matriz de ownership, decisiones y resultados medidos.

## Task 1: Baseline de aplicativos y matriz de ownership

**Files:**

- Create: `scripts/audit-application-ownership.sh`
- Create: `tests/application_ownership_test.sh`
- Create: `docs/audits/2026-09-02-application-integration.md`
- Test: `scripts/check-desktop-configs.sh`, `scripts/check.sh`

- [ ] Inventariar sólo archivos versionados y binarios disponibles. El script debe listar Kitty, Rofi, Albert, Dunst, Polybar, CopyQ, ble.sh, Atuin, FZF, Starship, zoxide, direnv, mise, fnm, LazyGit, Yazi, lnav, btop y Neovim con ruta de configuración, owner propuesto y teclas/comandos detectados.
- [ ] Hacer que `tests/application_ownership_test.sh` falle si una capacidad tiene más de un owner declarado: launcher de aplicaciones, historial, clipboard histórico, prompt, panes, ventanas, editor, Git visual o notificaciones.
- [ ] Registrar en `docs/audits/2026-09-02-application-integration.md` la matriz inicial, duplicaciones conocidas (Albert/Rofi y CopyQ/clipmenu), dependencias opcionales y archivos protegidos.
- [ ] Ejecutar `bash scripts/audit-application-ownership.sh`, `bash tests/application_ownership_test.sh`, `bash scripts/check.sh` y `bash scripts/check-desktop-configs.sh --static`; el baseline debe ser informativo y no cambiar comportamiento.
- [ ] Commit: `audit(apps): establish application ownership baseline`.

## Task 2: Rofi como selector visual común

**Files:**

- Modify: `stow/rofi/.config/rofi/config.rasi`
- Modify: `stow/i3/.config/i3/config`
- Modify/Create: `stow/i3/.config/i3/scripts/`
- Create: `tests/rofi_workflow_contract_test.sh`
- Modify: `docs/audits/2026-09-02-application-integration.md`

- [ ] Escribir primero un contrato que compruebe que `$mod+d` lanza aplicaciones, `$mod+f` selecciona ventanas, `$mod+v` abre clipboard y `$mod+q` usa `confirm_kill.sh`; debe fallar si aparece otro launcher para la misma acción.
- [ ] Mantener un único estilo Rofi y definir defaults de teclado: selección por flechas/`j/k`, `Enter` acepta y `Escape` cancela; no aceptar entradas libres en diálogos destructivos.
- [ ] Mantener `confirm_kill.sh` como owner del cierre de ventana y reutilizar el patrón `Cancelar`/`Cerrar` para futuras acciones confirmables.
- [ ] Auditar Albert antes de tocarlo. Si Rofi cubre todas sus acciones usadas, documentar Albert como launcher secundario pendiente de decisión; no desactivarlo automáticamente.
- [ ] Validar con `bash tests/rofi_workflow_contract_test.sh`, `bash scripts/check-desktop-configs.sh --static` y `git diff --check`.
- [ ] Commit: `feat(rofi): standardize keyboard-first selectors`.

## Task 3: ble.sh, Atuin y FZF como una sola capa de línea

**Files:**

- Modify: `stow/bash/.bashrc`
- Modify: `stow/bash/.bash_lib/keymap.sh`
- Modify: `stow/blesh/.config/blesh/blerc`
- Modify: `stow/blesh/.blerc` only if the active stow target requires it
- Create: `tests/blesh_integration_test.sh`
- Create: `docs/audits/2026-09-02-blesh-integration.md`

- [ ] Escribir un test que cargue un Bash interactivo aislado con ble.sh disponible y compruebe: `BLE_VERSION`, attach único, `C-r` owner Atuin/fallback, `C-t` owner selector de archivos, `M-c` owner selector de directorios y ausencia de sourcing de los bindings clásicos de FZF.
- [ ] Ejecutar el test en rojo antes de añadir opciones; cualquier fallo debe identificar una colisión concreta, no una diferencia de prompt.
- [ ] Configurar sólo syntax highlighting, autosuggestion y completion visual de ble.sh. No activar `set -o vi`, no cambiar `C-s` y no sustituir Starship.
- [ ] Importar una única integración FZF de ble.sh si el inventario demuestra que no está activa; si ya está activa, no cargar otra.
- [ ] Mantener los bindings efectivos de `stow/bash/.bash_lib/keymap.sh` como owner y hacer la configuración idempotente tras `reload` y nueva shell.
- [ ] Medir cinco arranques login y no-login con TTY real mediante `scripts/measure-shell-startup.sh`; no aceptar una configuración que empeore el presupuesto medido sin beneficio documentado.
- [ ] Validar `bash tests/blesh_integration_test.sh`, `bash scripts/check.sh`, `shellcheck`, `git diff --check` y un arranque interactivo aislado.
- [ ] Commit: `feat(blesh): integrate line editing without keymap collisions`.

## Task 4: Clipboard único entre desktop, tmux, Bash y Neovim

**Files:**

- Inspect/Modify: `stow/copyq/.config/copyq/`
- Inspect/Modify: `stow/bin/.local/bin/clipcopy`, `stow/bin/.local/bin/clippaste`
- Inspect/Modify: `stow/bash/.bashrc`, `stow/bash/.bash_lib/core.sh`
- Inspect/Modify: `stow/tmux/.tmux.conf`
- Inspect/Modify: `stow/kitty/.config/kitty/kitty.conf`
- Create: `tests/clipboard_ownership_test.sh`
- Create: `docs/audits/2026-09-02-clipboard-integration.md`

- [ ] Escribir un test de ownership que distinga transporte (`xsel`, `xclip`, `wl-copy`, `pbcopy`) de historial (`CopyQ`/`clipmenu`), evitando declarar cada backend como un clipboard manager distinto.
- [ ] Confirmar el flujo canónico: CopyQ conserva historial; Rofi/clipmenu selecciona historial; tmux copy-mode copia al sistema; Bash usa `pbcopy`/`pbpaste`; Neovim usa el clipboard del sistema.
- [ ] Eliminar sólo duplicaciones demostradas de bindings o autostart; mantener fallback X11/Wayland y modo sin clipboard gráfico.
- [ ] Validar cada backend con comandos simulados, sin sobrescribir el clipboard personal del usuario durante los tests.
- [ ] Ejecutar `bash tests/clipboard_ownership_test.sh`, `bash scripts/check-desktop-configs.sh --static`, tests Bash/Neovim y `git diff --check`.
- [ ] Commit: `fix(clipboard): define one history owner and transport fallbacks`.

## Task 5: Kitty, tmux, Polybar y Dunst como transporte/feedback

**Files:**

- Inspect/Modify: `stow/kitty/.config/kitty/kitty.conf`
- Inspect/Modify: `stow/tmux/.tmux.conf`, `stow/tmux/.tmux/scripts/`
- Inspect/Modify: `stow/polybar/.config/polybar/config.ini`
- Inspect/Modify: `stow/dunst/.config/dunst/dunstrc`
- Create: `tests/terminal_feedback_contract_test.sh`
- Modify: `docs/audits/2026-09-02-application-integration.md`

- [ ] Escribir contratos para conservar `C-s` como prefijo tmux, `C-h/j/k/l` como navegación tmux/Neovim, Alt+Shift+flechas como resize, `$mod` para i3 y ausencia de bindings Kitty que intercepten esas secuencias.
- [ ] Mantener Kitty como terminal y transporte; no añadir un tercer sistema de tabs/sesiones.
- [ ] Definir feedback por severidad: tmux/Polybar para estado persistente, Dunst para eventos, Rofi para decisiones y Neovim/Bash para contexto de trabajo.
- [ ] Revisar que el status de Git no se calcule duplicadamente en prompt, tmux y Polybar cuando el coste sea medible; no retirar información sin baseline.
- [ ] Validar `bash tests/terminal_feedback_contract_test.sh`, `bash scripts/check-desktop-configs.sh`, `bash scripts/check.sh`, y `git diff --check`.
- [ ] Commit: `chore(desktop): align terminal transport and feedback owners`.

## Task 6: Workflows de proyecto, Git, logs y filesystem

**Files:**

- Inspect/Modify: `stow/lazygit/.config/lazygit/config.yml`
- Inspect/Modify: `stow/yazi/.config/yazi/`
- Inspect/Modify: `stow/lnav/` y wrappers Bash Docker/Git
- Inspect/Modify: `stow/nvim/.config/nvim/`
- Modify: `docs/audits/2026-09-01-neovim-workflows.md`
- Create: `tests/application_workflow_contract_test.sh`

- [ ] Definir una secuencia canónica de backend: abrir proyecto con `tproj`, conservar contexto en tmux, editar con Neovim, ejecutar `<leader>p*`, revisar Git con LazyGit y consultar logs con lnav.
- [ ] Mantener `lg`, `C-s g` y `<leader>gg` como entradas equivalentes a Git visual.
- [ ] Mantener Yazi para filesystem desde Bash y Telescope/Neo-tree para navegación dentro del editor; no unificar artificialmente ambas interfaces.
- [ ] Documentar lnav como herramienta de logs de Docker/servidores y btop como monitorización, sin nuevos bindings globales salvo necesidad demostrada.
- [ ] Cubrir con un contrato que los comandos y mappings principales existen, que las dependencias opcionales producen fallback y que no se ejecutan operaciones mutantes durante el test.
- [ ] Validar todos los tests Bash/Neovim, `bash scripts/check-desktop-configs.sh`, `shellcheck`, secretos y `git diff --check`.
- [ ] Commit: `docs(workflows): define integrated project operations`.

## Task 7: Revisión de coherencia y documentación única

**Files:**

- Modify: `stow/nvim/.config/nvim/SHORTCUTS.md`
- Modify: `stow/nvim/.config/nvim/USAGE.md`
- Modify: documentación generada por `scripts/generate_shortcuts_doc.sh`
- Create: `docs/audits/2026-09-02-application-grammar.md`
- Create: `tests/application_grammar_test.sh`

- [ ] Generar una tabla única de owners y scopes: i3, Kitty, tmux, Bash/ble.sh, Neovim, Rofi, clipboard, feedback y proyecto.
- [ ] Verificar que las docs no presenten un binding como canónico si sólo existe en una capa distinta.
- [ ] Explicar explícitamente que `p/r/y/n/z` conservan semántica nativa en Vim y semántica de comando en Bash.
- [ ] Añadir ejercicios de memoria muscular por secuencia, no por lista de teclas: abrir proyecto, navegar panes, buscar historial, editar, testear, revisar Git, consultar logs y cerrar.
- [ ] Ejecutar `bash scripts/generate_shortcuts_doc.sh`, `bash tests/application_grammar_test.sh`, todos los checks estáticos y `git diff --check`.
- [ ] Commit: `docs(productivity): publish coordinated application grammar`.

## Task 8: Periodo de uso y segunda auditoría

**Files:**

- Create: `docs/audits/2026-09-16-application-friction-review.md`
- Create: `tests/application_release_gate_test.sh`

- [ ] Mantener las configuraciones sin nuevos cambios durante un periodo de uso de 1–2 semanas.
- [ ] Registrar sólo fricciones observadas al menos tres veces: tecla olvidada, conflicto, selector redundante, comando lento o feedback insuficiente.
- [ ] No usar historial privado de Bash/Atuin para inferir prioridades automáticamente; las decisiones deben proceder de observaciones explícitas y métricas públicas.
- [ ] Ejecutar la segunda auditoría comparando baseline y estado actual: startup Bash/Neovim, primera orden, carga de plugins, clipboard, Rofi, tmux/i3 y workflows backend.
- [ ] Retirar aliases o aplicativos sólo si hay evidencia de bajo uso, duplicación y ausencia de regresión; cada retirada tendrá commit y rollback independiente.
- [ ] El gate de release debe comprobar working tree limpio, tests completos, secretos, `git diff --check`, ausencia de cambios no autorizados en `.bashrc_local`, tmux e i3 y documentación actualizada.

## Orden de ejecución recomendado

1. Task 1: baseline y ownership.
2. Task 2: Rofi y selectores.
3. Task 3: ble.sh/Atuin/FZF.
4. Task 4: clipboard.
5. Task 5: Kitty/tmux/Polybar/Dunst.
6. Task 6: workflows de proyecto.
7. Task 7: documentación y ejercicios.
8. Task 8: uso real y segunda auditoría.

La implementación debe detenerse después de Task 7 para permitir adaptación. Task 8 no introduce funcionalidades por defecto: sirve para decidir con evidencia si merece la pena continuar.
