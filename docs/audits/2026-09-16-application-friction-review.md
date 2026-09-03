# Segunda auditoría de fricciones — 2026-09-16

## Estado

**PENDIENTE — requiere 1–2 semanas de uso real.** Este documento es una
plantilla de observación; no usa historial privado de Bash/Atuin ni presupone
qué comandos se utilizan más.

## Criterio de registro

Anotar sólo una fricción después de observarla al menos tres veces: tecla
olvidada, conflicto, selector redundante, comando lento o feedback insuficiente.
Registrar contexto y frecuencia observada, sin convertir la ausencia de una
observación en evidencia de bajo uso.

| Fecha | Contexto/workflow | Fricción observada | Veces | Evidencia pública | Acción propuesta |
|-------|-------------------|--------------------|-------|-------------------|------------------|
| — | — | PENDIENTE | — | — | — |
| 2026-09-03 | i3 autostart, launcher | Albert (`exec` en i3 config) autoarrancaba sin ningún keybind que lo invocara; Rofi ya cubría `drun`/`run`/`window`/clipmenu (4 binds activos) | N/A (verificado por ausencia total de invocación, no por conteo de fricción) | `pgrep`/`ps aux` sin ningún proceso vivo con keybind asociado; cero referencias a `albert` en `stow/i3/.config/i3/config` fuera del `exec` mismo | Retirado: línea `exec ... albert` eliminada de `stow/i3/.config/i3/config`, paquete `albert` desinstalado (ver `docs/inventario-aplicaciones-2026-09-03.md`) |
| 2026-09-03 | i3, gestión de contraseñas | Gap real (no fricción): sin autofill de contraseñas en terminal, solo `pass`/Bitwarden-navegador | — | `docs/inventario-aplicaciones-2026-09-03.md` — sección Bitwarden | Añadido `bindsym $mod+p exec rofi-bw` (script propio en `stow/bin/.local/bin/rofi-bw`, usa `bitwarden-cli`) — capacidad nueva, no compite con ningún bind existente (`$mod+p` estaba libre, verificado antes de asignarlo) |

## Comparación con el baseline

Cuando finalice el periodo, comparar contra:

- arranque Bash/Neovim y primera orden;
- carga de plugins y disponibilidad de dependencias opcionales;
- clipboard, Rofi, tmux/i3, Dunst y Polybar;
- workflow backend: `tproj`/`dev`, Neovim, tareas, LazyGit, `dlogs`/`lnav` y
  btop.

No se retirará ningún alias o aplicativo sólo por preferencia teórica. Una
retirada necesitará evidencia de duplicación, bajo uso observado y ausencia de
regresión, con commit y rollback independientes.

## Gate de release

`tests/application_release_gate_test.sh` comprueba checkout limpio, sintaxis,
configuración estática de escritorio, contratos de integración, documentación
presente y ausencia de cambios en tmux/i3 respecto a la base de esta fase
(`b81c3d1`; se puede sustituir con `APPLICATION_BASELINE_REF`).

Baseline movido de `974a4ec` a `b81c3d1` el 2026-09-03 tras documentar y
aprobar los dos cambios de esa fecha en `stow/i3/.config/i3/config` (ver
tabla arriba). Cualquier cambio posterior a `b81c3d1` en `i3/config` o
`tmux.conf` sigue bloqueado por el gate salvo que se documente igual.
