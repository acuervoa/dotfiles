# Integración de clipboard — 2026-09-02

## Decisión

`clipmenu` es el owner del historial visual y se abre con i3 `$mod+v` usando
Rofi. CopyQ permanece instalado/configurado como alternativa, pero no se
autoinicia porque una decisión previa estableció Clipmenu como autoridad.

## Separación de responsabilidades

| Capa | Owner | Función |
|---|---|---|
| Historial visual | clipmenu | listar y seleccionar clips |
| Selector visual | Rofi | interfaz de `clipmenu` y otros diálogos |
| Bash | `pbcopy`/`pbpaste`/`cb` | copiar o pegar mediante backend gráfico |
| tmux | `@copy_cmd` + `set-clipboard` | enviar copy-mode al clipboard del sistema |
| Kitty | `copy_to_clipboard`/`paste_from_clipboard` | selección y transporte de terminal |
| Neovim | provider de clipboard del sistema | copiar/pegar desde el editor |
| Backend | `wl-copy`, `xclip`, `xsel` | transporte X11/Wayland |

Los backends (`wl-copy`, `xclip`, `xsel`) no son historiales y no deben recibir
bindings propios. `CopyQ` tampoco debe arrancarse automáticamente mientras
`clipmenu` sea el owner canónico.

## Fallbacks

- Wayland: `wl-copy`/`wl-paste` si existe el socket y los binarios.
- X11: `xclip` y después `xsel` cuando `DISPLAY` está disponible.
- Sin backend gráfico: Bash informa del estado; `cb` puede usar OSC52 cuando
  dispone de TTY.
- tmux selecciona su backend según la sesión y mantiene `set-clipboard on`.

## Validación

```bash
bash tests/clipboard_ownership_test.sh
bash tests/bash_clipboard_test.sh
```

Los tests no escriben en el clipboard personal: el primero es estático y el
segundo simula backends aislados.
