# Auditoría general del workspace — 2026-09-01

## Alcance

Auditoría de solo lectura de las cuatro capas que forman el entorno
hiperproductivo: Bash, i3wm, tmux y Git. Se cruzaron los archivos
versionados, los enlaces Stow activos, los checks existentes y el estado
efectivo de i3/tmux. No se leyó `~/.bashrc_local`, no se leyó el historial
privado y no se modificaron configuraciones de usuario, i3 ni tmux.

El repositorio no tiene CodeGraph inicializado; la inspección estructural de
esta auditoría se hizo directamente sobre los archivos y los runtimes.

## Resultado ejecutivo

El sistema es funcional y tiene una base sólida de ownership:

- Bash carga módulos separados por responsabilidad y dispone de catálogo,
  tests de gramática, seguridad y compatibilidad.
- i3 carga la configuración versionada y la distribución de workspaces
  generada; el parser devuelve éxito.
- tmux está activo con prefijo `C-s`, una gramática consistente de panes,
  ventanas, sesiones y copy-mode, y los scripts auxiliares están versionados.
- Git tiene configuración conservadora (`pull --rebase`, `ff-only`, hooks,
  protección de push y escaneo de secretos).
- No se observan colisiones silenciosas entre namespaces. Las letras
  repetidas (`p`, `r`, `n`, `y`, `z`, `q`) pertenecen a contextos distintos y
  requieren prefijo/modificador para tmux e i3.

El objetivo aún no está completamente cerrado. La deuda relevante es de
reproducibilidad y operación: el include de i3 es generado por máquina,
faltaban validadores específicos de i3/tmux en CI, existe una superficie
amplia de plugins tmux y hay dos commits locales posteriores a la release.
El catálogo Bash ya incluye `z`, `pbcopy` y `pbpaste` en el estado actual.

## Estado y evidencias

| Área | Estado | Evidencia |
| --- | --- | --- |
| Bash | PASS con deuda documental | `scripts/check.sh`, suite `tests/bash_*_test.sh`, catálogo y módulos |
| i3wm | PASS en runtime | `i3 -C` correcto; i3 4.25.1 carga `~/.config/i3/config` y `workspaces.local.conf` |
| tmux | PASS en runtime | sesión `main` activa; tmux 3.7c; prefijo efectivo `C-s` |
| Git | PASS con deuda de publicación | `main` limpia, pero está 2 commits por delante de `origin/main` |
| Secretos | PASS | `scripts/check-secrets.sh` sin detecciones obvias |
| Sintaxis Bash | PASS | `bash -n` sobre entradas, módulos y scripts |
| CodeGraph | ATENCIÓN | no inicializado en este repositorio |

## 1. Bash

### Fortalezas

- Hay un owner claro por módulo: Git, Docker/PHP, navegación, runtime/QA,
  sistema, AI y keymap.
- El catálogo contiene 134 entradas; `z`, `pbcopy` y `pbpaste` están incluidos
  y se distinguen de las definiciones estáticas en el probe de runtime.
- La carga es razonablemente idempotente: `PROFILE_LOADED`, inicializadores
  de `mise`/`fnm`, deduplicación final de `PATH` y `ble-attach` una sola vez.
- Las acciones mutables importantes tienen confirmación o controles de
  rutas sensibles; Git, Docker, envswap y AI disponen de tests específicos.

### Riesgos y oportunidades

**P2 — runtime dinámico.** Aunque `z`, `pbcopy` y `pbpaste` ya están
catalogados, `z` procede de `zoxide init bash` y los wrappers de clipboard se
definen desde `.bashrc`. El contrato está documentado, pero la prueba de
runtime debe seguir distinguiendo definiciones estáticas y dinámicas.

**P1 — entrada interactiva pesada.** `.bashrc` inicializa de forma eager
bash-completion, ble.sh, Atuin, zoxide, direnv, Starship, mise y fnm, además
de ejecutar varias normalizaciones de `PATH`. Ya existe baseline y no hay
evidencia suficiente para aplicar lazy loading sin una comparación más fina.

**P2 — colisión cognitiva con binarios.** `cat`, `ls`, `grep`, `vim`, `gc`,
`gs`, `dc`, `dcb`, `trash` y `ts` ocultan binarios externos. Es compatible con
la configuración actual, pero dificulta depurar un entorno mínimo o usar
`command`/`type` de forma intuitiva.

**P2 — módulos grandes.** `ai.sh`, `misc.sh`, `core.sh` y `nav.sh` concentran
muchas responsabilidades. El ownership por grupo existe, pero el coste de
revisión y el riesgo de efectos laterales crecerán si siguen aumentando.

### Mejoras propuestas

1. Mantener una sección de “runtime público” en el catálogo para `z`,
   `pbcopy` y `pbpaste`, sin renombrarlos.
2. Medir cada inicializador con instrumentación repetible antes de decidir
   lazy loading; fijar un presupuesto de arranque y un presupuesto de primera
   orden.
3. Mantener aliases de compatibilidad, pero ofrecer una política explícita:
   `builtin`/`command` para recuperar el binario y documentación de los
   nombres que se sombrean.
4. Separar en módulos más pequeños solo al tocar una responsabilidad; no
   hacer una refactorización masiva sin baseline de comportamiento.

## 2. i3wm

### Fortalezas

- El runtime carga el archivo versionado y el include de workspaces generado.
- La gramática es legible: `Mod4` gestiona ventanas/workspaces; tmux gestiona
  panes/ventanas dentro del terminal; multimedia, scratchpads y screenshots
  tienen owners propios.
- Los comandos destructivos visibles (`Mod4+q`, salida de i3, lock y menú de
  sistema) incorporan confirmación o una ruta explícita.
- `outputs_apply.sh` ya evita el timestamp inestable que podía producir
  reloads recursivos; `picom` tiene guardia contra duplicación.

### Riesgos y oportunidades

**P1 — estado generado no reproducible por sí solo.**
`workspaces.local.conf` depende de outputs conectados y vive en `~/.config`.
Es correcto que sea dinámico, pero un clon limpio no puede reconstruirlo sin
ejecutar el script y disponer de X11/xrandr.

**P1 — ausencia de test automático del parser y de scripts i3.** La prueba
real de `i3 -C` depende de acceso a `/run`; en entornos aislados falla por
infraestructura, no por la configuración. Los scripts usan `i3-msg`, `jq`, X11
y procesos gráficos, pero no tienen un harness con mocks.

**P2 — carreras en scratchpads.** Los scripts esperan ventanas con bucles de
`sleep` y silencian parte de los errores. Si la aplicación tarda más o cambia
su WM_CLASS, el fallback puede terminar sin dejar un estado inequívoco.

**P2 — ciclo de vida de picom en screenshots.** El script mata picom durante
la captura y lo relanza al salir. Es funcional, pero puede perder opciones de
la instancia original o crear una condición de carrera durante reloads.

### Mejoras propuestas

1. Documentar `workspaces.local.conf` como artefacto generado y añadir un
   comando de bootstrap que lo regenere de forma explícita.
2. Crear un test estático que compruebe que todos los targets de `exec`,
   `include`, scripts y variables de i3 existen o estén marcados como
   opcionales.
3. Añadir tests de scripts con `i3-msg`/`jq` simulados, cubriendo ventana
   ausente, timeout y selección cancelada.
4. Reemplazar sleeps mágicos por timeout configurable y mensajes de error
   visibles; conservar la semántica actual de scratchpads.
5. Evaluar un owner único para picom (i3 o un servicio de sesión), dejando
   screenshots como consumidor y no como gestor de su ciclo de vida.

## 3. tmux

### Fortalezas

- Prefijo efectivo único `C-s`; `C-s` no es apropiado por Readline porque
  Bash desactiva `ixon`.
- Pane navigation `h/j/k/l`, splits `d/r`, zoom `z`, búsqueda `f`, sesiones
  `t/C-t/A`, copy-mode vi y clipboard tienen una semántica consistente.
- Los defaults destructivos (`q`, `BSpace`, kill pane) piden confirmación.
- Los scripts propios (`proj_session.sh`, `git_status.sh`, etc.) están en
  `stow/tmux/.tmux/scripts` y son enlazados por Stow.
- La configuración runtime fue validada con una sesión activa: `main`, una
  ventana, `status-interval 5`, prefix `C-s`.

### Riesgos y oportunidades

**P1 — superficie de plugins amplia.** Hay aproximadamente diez plugins
activos, además de scripts propios y bindings de fzf/extrakto/sessionx.
Aumenta el tiempo de diagnóstico, la variabilidad entre máquinas y la
probabilidad de ownership duplicado.

**P1 — status dinámico periódico.** `status-right` ejecuta
`git_status.sh` mediante `#()` cada cinco segundos. En muchas ventanas o
repositorios grandes puede convertirse en trabajo permanente y competir con
la experiencia interactiva.

**P2 — fallback local implícito.** `source-file -q ~/.tmux.conf.local` es
correcto para personalización, pero su contenido y compatibilidad no están
representados en el repositorio. El comportamiento efectivo puede variar sin
una pista en Git.

**P2 — validación contextual incompleta.** El parseo aislado necesita socket y
runtime tmux; los checks actuales validan Bash, pero no garantizan que cada
plugin, script y opción de tmux exista en una instalación mínima.

### Mejoras propuestas

1. Inventariar plugins por valor real y marcar cada binding como core,
   plugin o compatibilidad; retirar solo después de observar uso y tener
   sustituto.
2. Cachear o espaciar el estado Git del status, con degradación silenciosa si
   el directorio no es un repositorio; medir antes y después.
3. Añadir un `tmux-check.sh` que arranque un servidor con socket temporal,
   desactive TPM y verifique parseo, prefix, bindings críticos y scripts.
4. Documentar `~/.tmux.conf.local` como extensión no versionada y comprobar
   que su ausencia conserva el comportamiento base.
5. Mantener la gramática actual; no añadir más teclas hasta reducir la
   superficie de plugins y comprobar que los bindings core se recuerdan.

## 4. Git

### Fortalezas

- `pull --rebase`, `merge.ff=only`, `fetch.prune`, `push.autoSetupRemote` y
  `followTags` reducen sorpresas en el flujo diario.
- Hook `pre-commit`, hook `commit-msg`, plantilla y escaneo de secretos están
  versionados o documentados.
- La auditoría previa no encontró corrupción ni secretos obvios.
- Los wrappers Bash protegen push, force-with-lease, staging sensible y
  operaciones destructivas.

### Riesgos y oportunidades

**P1 — publicación pendiente.** `main` está dos commits por delante de
`origin/main`: la auditoría general y la corrección del warning de ShellCheck
son locales. La release `v2026.09.01` sigue apuntando al commit anterior.

**P1 — hooks no autosuficientes en un clon limpio.** Git usa
`core.hooksPath=~/.git-hooks`, que actualmente apunta al contenido Stow. Un
clon nuevo no obtiene automáticamente ese enlace ni el hook path.

**P2 — ramas/worktree antiguos.** Existen ramas alcanzadas por `main` y un
worktree activo de `tmux-key-grammar`; no deben borrarse automáticamente.

**P2 — firma de procedencia ausente.** No hay firma SSH/GPG activa para
commits o tags. El tag de release es anotado, pero no firmado.

### Mejoras propuestas

1. Publicar los dos commits locales en un cambio separado y decidir si
   corresponde una release de parche; no mezclar esa decisión con limpieza.
2. Añadir al bootstrap una instalación idempotente de `core.hooksPath` y una
   prueba que confirme permisos y ejecución de ambos hooks.
3. Preparar un informe de ramas/worktrees para revisión antes de eliminar
   referencias; conservar objetos dangling hasta confirmar que no son útiles.
4. Evaluar firma SSH de commits/tags como mejora independiente de la
   configuración funcional.
5. Añadir checks de política: rama protegida, working tree limpio antes de
   release, tag anotado y release apuntando al commit publicado.

## Ownership transversal recomendado

| Responsabilidad | Owner recomendado | Consumidores |
| --- | --- | --- |
| Comandos de proyecto | módulos Bash y catálogo | i3 abre Kitty/tmux; tmux conserva contexto |
| Layout de terminal | tmux | Bash, Neovim, plugins tmux |
| Layout de aplicaciones | i3 | Kitty, Polybar, scratchpads, apps gráficas |
| Clipboard | resolver Bash/tmux/i3 según contexto | Bash, copy-mode, screenshots |
| Estado Git | funciones Bash + `git_status.sh` tmux | prompt/status, workflows y release |
| Instalación reproducible | Stow/bootstrap | todas las capas |
| Validación | `scripts/check.sh` + checks por capa | commits y releases |

Regla operativa: un componente puede ser consumidor de otro, pero no debe
duplicar su lógica. i3 lanza tmux; tmux conserva el proyecto; Bash opera el
proyecto; Git valida y publica el resultado.

## Roadmap priorizado hacia el objetivo

### P0 — cerrar publicación y evidencia

- Publicar o etiquetar explícitamente los dos commits posteriores a la
  release.
- Mantener `scripts/check.sh`, tests Bash, `bash -n` y escaneo de secretos en
  verde.
- Registrar que la checklist manual queda diferida por decisión del usuario.

### P1 — reproducibilidad y checks automáticos

- Bootstrap idempotente para hooks, links Stow e include generado de i3.
- `tmux-check.sh` aislado y test estático de targets i3.
- Catálogo Bash completo con runtime dinámico documentado.

### P1 — medición antes de optimización

- Medir carga de Bash por componente.
- Medir coste del status tmux y de los plugins.
- Establecer presupuestos y solo después aplicar lazy loading/cache.

### P2 — simplificación controlada

- Reducir plugins tmux según evidencia de uso.
- Endurecer timeouts y errores de scratchpads.
- Separar módulos Bash grandes solo cuando haya una modificación concreta.
- Evaluar firma Git y limpieza de ramas/worktrees con confirmación explícita.

## Limitaciones

- No se ejecutó una checklist manual completa de Kitty/i3/tmux, de acuerdo
  con la decisión del usuario.
- El runtime de i3/tmux sí se consultó, pero el estado observado es el de la
  sesión actual y no sustituye pruebas de reinicio, ausencia de dependencias
  ni múltiples monitores.
- CodeGraph no está inicializado en este repositorio.

## Criterio de llegada

El objetivo inicial se considera alcanzado cuando cada comando, binding,
script y flujo tiene owner identificable; los checks por capa son ejecutables
en un clon limpio; Bash mantiene su presupuesto de arranque; tmux/i3 no
duplican lógica; Git puede instalar sus controles y publicar una release
reproducible; y una segunda auditoría tras uso real no encuentra regresiones.
