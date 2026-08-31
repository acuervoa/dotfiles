# Diseño: clipboard coherente en Bash

## Objetivo

Hacer que las interfaces de clipboard de Bash (`pbcopy`, `pbpaste` y `cb`)
seleccionen el backend por el protocolo gráfico activo, no por la mera
instalación de binarios. La configuración debe comportarse igual que tmux en
la workstation X11 actual.

## Contrato

1. Si `WAYLAND_DISPLAY` apunta a un socket válido y están disponibles
   `wl-copy`/`wl-paste`, usar Wayland.
2. En caso contrario, si existe `DISPLAY` y está disponible `xclip`, usar
   `xclip -selection clipboard`.
3. Mantener los fallbacks actuales de `cb` para entornos compatibles, sin
   hacer que la presencia de `wl-copy` tenga prioridad falsa.
4. Si no hay backend válido, las funciones deben fallar con un diagnóstico
   claro y sin tragarse silenciosamente la entrada.

## Implementación

El resolver vivirá en una única función interna del módulo de navegación o
clipboard. `pbcopy` y `pbpaste` delegarán en ella; `cb` la reutilizará para no
mantener dos políticas de detección divergentes. La selección se realizará al
ejecutar la función, permitiendo cambiar de sesión gráfica sin recargar Bash.

No se introducen aliases nuevos ni se cambian nombres públicos.

## Validación

- `bash -n` sobre `.bashrc` y módulos.
- Shell interactiva cargada: `type pbcopy`, `type pbpaste`, `type cb`.
- En la sesión confirmada (`DISPLAY=:0`, `WAYLAND_DISPLAY` vacío), verificar
  que el backend seleccionado sea X11.
- Copiar y pegar un token de prueba mediante `pbcopy`, `pbpaste` y `cb`.
- Verificar que un reload de `.bashrc` no duplique funciones ni cambie el
  backend inesperadamente.
- Confirmar que `git diff` no incluya tmux ni i3.

## Fuera de alcance

- PATH y perfiles de login.
- Coste de arranque de Bash.
- Atuin, ble.sh, Starship, mise, fnm, AgentMemory y OpenClaw.
- Cambios en tmux, i3 o sus documentos.

