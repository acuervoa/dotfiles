# Baseline de rendimiento Bash — 2026-09-01

## Alcance

Medición de sólo lectura posterior a la auditoría de comandos. No se
aplicaron cambios de carga diferida ni se modificó ninguna configuración.
La ejecución usa `script` para proporcionar un pseudo-TTY y
`TERM=xterm-256color`. Cada cifra son cinco ejecuciones; se informa la
mediana. El coste de cada componente aislado incluye el coste fijo de crear
una Bash interactiva y, por tanto, no debe sumarse como si fuera aditivo.

## Arranque completo

| Shell | Mediciones (s) | Mediana |
| --- | --- | ---: |
| No-login: `bash -ic exit` | 0.479, 0.310, 0.335, 0.290, 0.284 | **0.310** |
| Login: `bash -lic exit` | 0.672, 0.600, 0.624, 0.627, 0.879 | **0.627** |

Presupuesto provisional para comparar cambios: mantener la mediana no-login
por debajo de 0.35 s y la login por debajo de 0.70 s hasta disponer de una
medición directa dentro de Kitty.

## Componentes aislados

| Componente | Mediana (s) | Lectura |
| --- | ---: | --- |
| `.profile` | 0.024 | entorno general y PATH |
| `.bash_profile` | 0.281 | dispatcher login; incluye `.profile` y `.bashrc` |
| `.bashrc` | 0.256 | configuración interactiva completa |
| bash-completion | 0.050 | carga independiente |
| Atuin | 0.059 | `atuin init bash --disable-up-arrow` |
| ble.sh | 0.024 | `ble.sh --noattach` |
| zoxide | 0.031 | `zoxide init bash` |
| direnv | 0.031 | `direnv hook bash` |
| Starship | 0.056 | `starship init bash` |
| mise | 0.125 | `mise activate bash` |
| fnm | 0.036 | `fnm env --use-on-cd --shell=bash` |
| `.bashrc_local` | 0.027 | sólo se midió su carga; no se reprodujo su contenido |

El mayor componente individual observado es `mise activate bash`, seguido de
Atuin, Starship y bash-completion. La cifra de `.bashrc` ya contiene varias
de estas cargas y no prueba por sí sola que una optimización concreta sea
beneficiosa.

## PATH y duplicados

La sesión login produjo un PATH efectivo sin entradas duplicadas. El orden
observado mantiene delante:

```text
$HOME/.local/bin
$HOME/bin
$HOME/.bun/bin
$HOME/.opencode/bin
$HOME/.local/share/composer/vendor/bin
```

Después aparecen Codex temporal, fnm, Juliaup, Cargo y las rutas del sistema.
No se detecta un problema de duplicación que justifique cambios en esta
iteración.

## Limitaciones

- `script` proporciona TTY, pero no es una ventana Kitty real bajo i3/tmux;
  debe repetirse allí antes de fijar un presupuesto definitivo.
- No se modificó ni se mostró el contenido de `.bashrc_local`; su cifra es
  únicamente tiempo de carga.
- No se midieron comandos de primera orden ni latencia de interacción.
- No se hizo carga diferida: este documento es baseline, no una propuesta de
  implementación.

## Siguiente decisión

Antes de tocar `.bashrc`, repetir el mismo protocolo dentro de Kitty, con y
sin tmux, y medir la primera orden. Sólo los componentes cuyo coste sea
relevante en esa medición deben considerarse para carga diferida.
