# Diseño: AgentMemory como servicio de usuario

## Objetivo

Sacar AgentMemory del camino crítico de cada shell Bash y ejecutarlo como una
única unidad `systemd --user`, evitando procesos duplicados cuando el backend
no está disponible.

## Unidad

La unidad vivirá en:

```text
stow/systemd/.config/systemd/user/agentmemory.service
```

Su contrato será:

- `ExecStart=/home/acuervo/.local/share/fnm/aliases/default/bin/agentmemory`.
- `Restart=on-failure`.
- `RestartSec=5`.
- `WantedBy=default.target`.
- Sin API keys, tokens ni `EnvironmentFile` versionados.
- Logs gestionados por journald del usuario.

El alias `fnm/default` evita fijar una versión concreta de Node, pero exige que
la instalación activa por defecto contenga AgentMemory; se verificará antes de
activar la unidad.

## Bash

Se eliminará exclusivamente el bloque que hace `curl` contra
`127.0.0.1:3111/agentmemory/health` y lanza `nohup agentmemory`. No se
modificarán los comandos AI, aliases, funciones, PATH, tmux ni i3.

## Activación y readiness

Después de instalar el paquete Stow:

```bash
systemctl --user daemon-reload
systemctl --user enable --now agentmemory.service
```

La unidad se considerará operativa sólo si `systemctl --user is-active` es
`active`, existe un listener REST esperado y
`curl http://127.0.0.1:3111/agentmemory/health` responde correctamente. Si
`iii-engine` no llega a estar disponible, el fallo se observará en
`journalctl --user -u agentmemory.service`; no se lanzarán instancias desde
Bash.

## Validación

- Test Bash que compruebe que `.bashrc` ya no contiene el autostart por shell.
- `bash -n` sobre configuración y scripts.
- Validación sintáctica de la unidad con `systemd-analyze --user verify` o
  equivalente disponible.
- Arranques repetidos de Bash sin crecimiento de procesos AgentMemory.
- Estado y logs de la unidad tras `enable --now`.
- Confirmar que tmux/i3 no aparecen en el diff.

## Fuera de alcance

- Reparar o actualizar `iii-engine`.
- Cambiar puertos de AgentMemory o configuración MCP de OpenCode.
- Copiar secretos desde `~/.agentmemory/.env` o `.bashrc_local`.
- Crear un servicio system-wide.

