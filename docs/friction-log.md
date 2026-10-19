# Registro de fricciones

> Periodo de uso cerrado el 2026-10-08 (Task 8 de `docs/superpowers/plans/2026-09-02-application-productivity-coordination.md`).
> Solo cuentan las fricciones observadas **al menos 3 veces**. Durante el periodo no se cambió la configuración, salvo para arreglar algo roto.

| Fecha | Fricción (tecla olvidada, conflicto, selector redundante, comando lento, feedback confuso) | Veces | Contexto |
|---|---|---|---|
| 2026-10-18 | `wl "texto"` antes de `wl init` crea `~/.local/share/worklog/<host>/` y luego `wl init` falla con «ya existe y no está vacío»; hay que mover o borrar el directorio a mano | 1 | Prueba E2E de `wl` en sandbox |
| 2026-10-18 | `wl sync` justo tras `wl init` contra un remoto vacío y sin entradas falla con «push falló… src refspec HEAD no concuerda»; el mensaje no dice que simplemente no hay nada que subir | 1 | Prueba E2E de `wl` en sandbox |
| 2026-10-18 | `wl daily` sin `--vault` (o con `--date` mal tecleado antes del flag) se registra como entrada «daily» en vez de dar error de uso | 1 | Diseño documentado en `is_command`, pero fácil de ensuciar el log |
| 2026-10-18 | Esta máquina no tenía worklog inicializado (sin `~/.local/share/worklog` ni `~/.config/worklog/host`): `wl sync` real no se pudo probar y el host caía al hostname (`iMac`) | 1 | Resuelta 2026-10-19: `wl` versionado en `stow/bin` (`dfdd782`) y `wl init … --host arch-main` hecho; `wl sync` real verificado (commit `b35369e` en el remoto) |
