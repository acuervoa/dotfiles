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
(`974a4ec`; se puede sustituir con `APPLICATION_BASELINE_REF`).
