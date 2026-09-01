# Memoria muscular de Bash

Esta guía sirve para practicar comandos existentes sin cambiar sus nombres ni
su comportamiento. La fuente de la gramática es [`stow/bash/.bash_grammar`](../stow/bash/.bash_grammar);
el catálogo resumido está en [`BASH_SHORTCUTS.md`](../BASH_SHORTCUTS.md) y los
recorridos completos en [`docs/bash-workflows.md`](bash-workflows.md).

## Microcomandos

| Comando | Acción | Práctica segura | Dependencia/precondición | Verificación |
| --- | --- | --- | --- | --- |
| `l` | Listar con el `ls` del sistema | Ejecutarlo en un directorio conocido y observar la salida | Bash cargado y un directorio accesible | Confirmar que muestra el contenido esperado |
| `n` | Abrir Neovim | Abrir un archivo de lectura o salir sin guardar | Neovim instalado; archivo o directorio accesible | Confirmar que Neovim abre y que `:q` sale sin cambios |
| `p` | Ejecutar PHP en el servicio `php` | Usar una consulta de versión o ayuda, como `p -v` | Proyecto con servicio `php` disponible | Confirmar la versión o ayuda y que no hubo mutación |
| `r` | Editar y reejecutar el penúltimo comando | Practicar sólo después de un comando de lectura; rechazar confirmación si propone mutar | Historial Bash con un comando anterior y editor configurado | Confirmar que se editó/reintentó la entrada prevista o cancelar sin cambios |
| `y` | Abrir Yazi | Entrar en una carpeta de prueba y salir sin operaciones de archivo | Yazi instalado y terminal interactiva | Confirmar que el selector abre y que salir conserva el estado |
| `z` | Cambiar directorio con zoxide | Buscar un destino conocido y comprobarlo antes de continuar | `zoxide init bash` cargado y destino registrado | Ejecutar `pwd` y confirmar el directorio esperado |

## Ejercicios de workflow

Cada ejercicio empieza observando el estado y acaba con una validación
read-only. En la primera pasada no ejecutes comandos mutantes que no preguntan;
practica sólo inspección y lectura. Cuando un comando sí muestre una
confirmación, responde `n` y comprueba que el estado queda intacto.

### Backend PHP

1. **Inspección:** revisa `gs` y comprueba el servicio Compose con `docps`;
   requiere estar en un proyecto Compose.
2. **Práctica:** ejecuta `p -v`, `proute` o `ptest`. No ejecutes `pint`, `part`,
   `pmig` ni `pseed` en la primera pasada; `pint` y `part` no preguntan, y si
   `pmig` o `pseed` muestran confirmación, responde `n`.
3. **Validación:** ejecuta `qa` y, si corresponde, `ptest`; vuelve a `gs` y
   confirma que el estado coincide con el observado al inicio.

### Servidores

1. **Inspección:** ejecuta `ports` y `topme`; revisa los logs disponibles con
   `dlogs` sólo si estás en un proyecto Compose, `fzf` está disponible y el
   servicio o contenedor está en ejecución.
2. **Práctica:** no ejecutes `rserve` en la primera pasada; observa el estado
   con `ports` y `topme`. Si usas `dlogs`, deben cumplirse las precondiciones
   de proyecto Compose, `fzf` disponible y servicio o contenedor en ejecución;
   sal de los logs con `Ctrl-C`.
3. **Validación:** vuelve a ejecutar `ports` y `topme`, revisa `dlogs` y termina
   sólo con las precondiciones de proyecto Compose, `fzf` disponible y servicio
   o contenedor en ejecución; sal de los logs con `Ctrl-C` y termina con `rqa` o
   `rtest`.

### Git

1. **Inspección:** ejecuta `gs`, `gd` y `gds` para entender estado, diff de
   trabajo y staging.
2. **Práctica:** no ejecutes `ga`, `gcm` ni `wip` en la primera pasada; revisa
   sólo `glast`, `ggraph` o `branch`. No prepares staging ni crees commits.
   No ejecutes `gclean`, `gundo`, `gpf` ni `gp`; si alguno muestra
   confirmación, responde `n`.
3. **Validación:** repite `gs` y `gds`, y ejecuta `qa`, `rqa` o `rtest` según
   el proyecto.

### Docker

1. **Inspección:** situado en un proyecto Compose, ejecuta `docps` y `dps`;
   consulta `dlogs` sólo con proyecto Compose, `fzf` disponible y servicio o
   contenedor en ejecución; sal de los logs con `Ctrl-C`. `docps` y `dcu`
   requieren un proyecto Compose.
2. **Práctica:** no ejecutes `dsh` ni `dcu` en la primera pasada; lee `dlogs`
   sólo con proyecto Compose, `fzf` disponible y servicio o contenedor en
   ejecución, y sal de sus logs con `Ctrl-C`. No ejecutes `dclean`, `dcrb` ni
   `dorebuild`; si alguno muestra confirmación, responde `n`.
3. **Validación:** repite `docps`; revisa `dlogs` sólo con proyecto Compose,
   `fzf` disponible y servicio o contenedor en ejecución, sal de los logs con
   `Ctrl-C` y termina con `rtest`, `qa` o `rqa`.

### AI

1. **Inspección:** consulta el estado y las candidatas con `sbo` y localiza un
   borrador con `aflastdraft`. `sbs` inicia una sesión nueva y requiere una
   tarea; `afl` inicia AI Flow, lanza un agente y también requiere una tarea.
   Hay una deriva conocida: `.bash_grammar` conserva etiquetas históricas para
   `sbo`, `sbs` y `sbsb` que no coinciden con el runtime observado; por ejemplo,
   etiqueta `sbo` como mutating y `sbs` como safe, aunque el runtime y
   `docs/bash-workflows.md` los usan como consulta (`sbo`) e inicio (`sbs`).
   Estos drills siguen el runtime observado, no modifican el catálogo en esta
   fase, y dejan la reconciliación del catálogo para una fase posterior.
2. **Práctica:** no ejecutes `sbs` ni `afl` sin una tarea definida. No ejecutes
   `afapplylast`, `sbe` ni `afx` en la primera pasada; revisa el draft y el
   estado sólo con `aflastdraft` y `sbo`.
3. **Validación:** vuelve a consultar con `sbo` y `aflastdraft`, y valida el
   resultado en el proyecto con `gs`, `qa`, `rqa` o `rtest`, según corresponda.

## Plantilla de fricción

Registra una observación concreta con estos campos exactos:

- Fecha:
- Contexto: Bash / tmux / i3 / Readline
- Secuencia intentada:
- Comando o tecla dudosa:
- Resultado observado:
- ¿Hubo confirmación o rollback?:
- Acción propuesta: observar / documentar / cambiar en fase posterior.

Una sola observación no retira un comando. Se requiere una segunda auditoría
tras uso real antes de proponer retirar, renombrar o cambiar cualquier atajo.
