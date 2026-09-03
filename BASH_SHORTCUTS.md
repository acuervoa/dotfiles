# Bash shortcuts · gramática operativa

Catálogo generado desde `stow/bash/.bash_grammar`.

Riesgo: ✅ seguro · ⚠ confirmación · 🔴 mutación.

## Micro-atajos

| Tecla | Acción | Grupo |
| --- | --- | --- |
| `l` | Listar con el ls del sistema | `navigation` |
| `n` | Abrir Neovim | `utility` |
| `p` | Ejecutar PHP en el servicio php | `php` |
| `r` | Editar y reejecutar el penúltimo comando | `runtime` |
| `y` | Abrir Yazi | `navigation` |
| `z` | Cambiar directorio con zoxide | `navigation` |

## Git (`g*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `branch` | Listar ramas ordenadas por actividad | ✅ seguro | `branch` |
| `checkpoint` | Guardar un checkpoint en stash | 🔴 mutación | `checkpoint` |
| `fixup` | Crear commit fixup contra otro commit | 🔴 mutación | `fixup` |
| `ga` | Añadir todos los cambios al staging | 🔴 mutación | `ga` |
| `gbr` | Seleccionar y cambiar de rama | 🔴 mutación | `gbr` |
| `gc` | Crear un commit interactivo | 🔴 mutación | `gc` |
| `gclean` | Borrar ramas locales ya mergeadas | ⚠ confirmación | `gclean` |
| `gcm` | Crear un commit con mensaje | 🔴 mutación | `gcm "mensaje"` |
| `gco` | Cambiar o restaurar checkout | 🔴 mutación | `gco rama` |
| `gcob` | Crear rama con checkout | 🔴 mutación | `gcob feature` |
| `gcof` | Seleccionar rama con histórico | 🔴 mutación | `gcof` |
| `gd` | Mostrar diff de trabajo | ✅ seguro | `gd` |
| `gds` | Mostrar diff staged | ✅ seguro | `gds` |
| `gdt` | Diff estructural (difftastic) puntual | ✅ seguro | `gdt` |
| `gfa` | Actualizar referencias remotas y podar | ✅ seguro | `gfa` |
| `gfeat` | Crear rama de feature | 🔴 mutación | `gfeat nombre` |
| `gfix` | Crear rama de fix | 🔴 mutación | `gfix nombre` |
| `ggraph` | Mostrar historial gráfico | ✅ seguro | `ggraph` |
| `gl` | Mostrar historial gráfico reciente | ✅ seguro | `gl` |
| `glast` | Mostrar último commit | ✅ seguro | `glast` |
| `gmain` | Cambiar a la rama principal | 🔴 mutación | `gmain` |
| `gp` | Push protegido de la rama actual | ⚠ confirmación | `gp` |
| `gpf` | Force-push protegido con lease | ⚠ confirmación | `gpf` |
| `grt` | Ir a la raíz del repositorio | ✅ seguro | `grt` |
| `gs` | Mostrar estado corto del repositorio | ✅ seguro | `gs` |
| `gst` | Mostrar estado del repositorio | ✅ seguro | `gst` |
| `gstaged` | Mostrar lo que se va a commitear | ✅ seguro | `gstaged` |
| `gsw` | Cambiar de rama con switch | 🔴 mutación | `gsw rama` |
| `gundo` | Deshacer último commit conservando cambios | ⚠ confirmación | `gundo` |
| `gup` | Actualizar con pull rebase y autostash | 🔴 mutación | `gup` |
| `lg` | Abrir Lazygit | ✅ seguro | `lg` |
| `recent` | Abrir archivos tocados recientemente | ✅ seguro | `recent` |
| `watchdiff` | Observar cambios locales en vivo | ✅ seguro | `watchdiff` |
| `wip` | Crear commit temporal de trabajo | 🔴 mutación | `wip` |

## Docker (`d*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `dc` | Atajo de Docker Compose | ✅ seguro | `dc ps` |
| `dcb` | Construir servicios Compose | 🔴 mutación | `dcb` |
| `dcd` | Parar servicios Compose | 🔴 mutación | `dcd` |
| `dclean` | Limpiar recursos Docker no usados | ⚠ confirmación | `dclean` |
| `dcp` | Descargar imágenes Compose | 🔴 mutación | `dcp` |
| `dcr` | Reiniciar servicios Compose | 🔴 mutación | `dcr` |
| `dcrb` | Reconstruir sin caché y arrancar servicios | ⚠ confirmación | `dcrb` |
| `dcu` | Arrancar servicios Compose | 🔴 mutación | `dcu` |
| `dcud` | Arrancar servicios Compose en segundo plano | 🔴 mutación | `dcud` |
| `dil` | Listar imágenes Docker | ✅ seguro | `dil` |
| `dlogs` | Seguir logs de un servicio | ✅ seguro | `dlogs` |
| `docps` | Mostrar estado normalizado de Compose | ✅ seguro | `docps` |
| `dorebuild` | Reconstruir Compose sin caché | ⚠ confirmación | `dorebuild` |
| `dps` | Listar contenedores Docker en ejecución (tabla) | ✅ seguro | `dps` |
| `dpsa` | Listar todos los contenedores Docker, incluye parados (tabla) | ✅ seguro | `dpsa` |
| `dsh` | Entrar en un servicio Compose | 🔴 mutación | `dsh` |
| `dshp` | Entrar directamente en php | 🔴 mutación | `dshp` |

## PHP/Laravel (`p*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `p` | Ejecutar PHP en el servicio php | 🔴 mutación | `p -v` |
| `part` | Ejecutar Artisan | 🔴 mutación | `part route:list` |
| `pcc` | Limpiar caché de Laravel | 🔴 mutación | `pcc` |
| `pcf` | Regenerar caché de configuración | 🔴 mutación | `pcf` |
| `pclear` | Limpiar cachés comunes Laravel | ⚠ confirmación | `pclear` |
| `php_new` | Crear microservicio PHP desde skeleton | 🔴 mutación | `php_new app` |
| `pint` | Formatear con Pint | 🔴 mutación | `pint` |
| `pmig` | Ejecutar migraciones Laravel | ⚠ confirmación | `pmig` |
| `proute` | Listar rutas Laravel | ✅ seguro | `proute` |
| `pseed` | Ejecutar seeders Laravel | ⚠ confirmación | `pseed` |
| `pstan` | Ejecutar PHPStan | ✅ seguro | `pstan` |
| `ptest` | Ejecutar PHPUnit | ✅ seguro | `ptest` |

## Runtime/QA (`r*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `dev` | Arrancar el entorno de desarrollo | 🔴 mutación | `dev` |
| `qa` | Ejecutar calidad del proyecto | ✅ seguro | `qa` |
| `r` | Editar y reejecutar el penúltimo comando | 🔴 mutación | `r` |
| `redo` | Reejecutar directamente el penúltimo comando | 🔴 mutación | `redo` |
| `rqa` | Ejecutar pipeline de calidad | ✅ seguro | `rqa` |
| `rserve` | Arrancar servidor de desarrollo | 🔴 mutación | `rserve` |
| `rtest` | Ejecutar tests del proyecto actual | ✅ seguro | `rtest` |
| `tswitch` | Cambiar entre modos del proyecto | 🔴 mutación | `tswitch` |

## AI Flow (`af*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `af` | Iniciar AI Flow con una tarea | ✅ seguro | `af "revisar cambios"` |
| `afa` | Aplicar una destilación AI Flow | 🔴 mutación | `afa` |
| `afapplylast` | Aplicar el último draft de destilación | 🔴 mutación | `afapplylast` |
| `afc` | Ejecutar un ciclo AI Flow | ✅ seguro | `afc` |
| `afd` | Generar una destilación AI Flow | 🔴 mutación | `afd` |
| `afdb` | Procesar sesiones históricas pendientes | 🔴 mutación | `afdb --list` |
| `afdp` | Ejecutar pipeline de destilación | 🔴 mutación | `afdp --dry-run` |
| `afl` | Iniciar AI Flow y lanzar agente | ✅ seguro | `afl "revisar cambios"` |
| `aflastdraft` | Localizar el último draft de destilación | ✅ seguro | `aflastdraft` |
| `afs` | Iniciar AI Flow | ✅ seguro | ` afs` |
| `afx` | Ejecutar ciclo con cierre y siguiente paso | 🔴 mutación | `afx "tarea"` |
| `ai` | Iniciar o cerrar una sesión AI | 🔴 mutación | `ai` |
| `codex-here` | Lanzar Codex en el directorio actual | ✅ seguro | `codex-here` |
| `gpt` | Abrir la webapp de ChatGPT | ✅ seguro | `gpt` |
| `gpt-safe` | Abrir ChatGPT sin aceleración GPU | ✅ seguro | `gpt-safe` |
| `ia` | Abrir entorno tmux para IA | ✅ seguro | `ia` |

## SimpleBrain (`sb*`)

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `sb-lint` | Auditar frontmatter del vault | ✅ seguro | `sb-lint` |
| `sbclose` | Cerrar formalmente un proyecto | 🔴 mutación | `sbclose "proyecto"` |
| `sbe` | Cerrar una sesión SimpleBrain | 🔴 mutación | `sbe` |
| `sbl` | Listar sesiones SimpleBrain | ✅ seguro | `sbl` |
| `sbo` | Consultar sesión activa y sesiones candidatas | ✅ seguro | `sbo` |
| `sbo-archive-stale` | Archivar sesiones stale | 🔴 mutación | `sbo-archive-stale` |
| `sbo-clean` | Limpiar sesiones huérfanas | 🔴 mutación | `sbo-clean` |
| `sbprofile` | Copiar el perfil compacto al portapapeles | ✅ seguro | `sbprofile` |
| `sbs` | Iniciar sesión SimpleBrain y registrar estado/artefactos | 🔴 mutación | `sbs` |
| `sbsb` | Iniciar sesión SimpleBrain instrumentada y registrar estado/artefactos | 🔴 mutación | `sbsb` |

## Navegación

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `..` | Subir un nivel | ✅ seguro | `..` |
| `...` | Subir dos niveles | ✅ seguro | `...` |
| `cb` | Copiar archivo o stdin al portapapeles | 🔴 mutación | `cb archivo` |
| `cdf` | Cambiar a directorio seleccionado | 🔴 mutación | `cdf` |
| `extract` | Extraer un archivo comprimido | 🔴 mutación | `extract archivo.tar` |
| `fo` | Buscar y abrir archivos | ✅ seguro | `fo` |
| `l` | Listar con el ls del sistema | ✅ seguro | `l` |
| `la` | Listar archivos ocultos | ✅ seguro | `la` |
| `ll` | Listar archivos con detalles | ✅ seguro | `ll` |
| `ls` | Listar archivos | ✅ seguro | `ls` |
| `pbcopy` | Copiar stdin al portapapeles | 🔴 mutación | `pbcopy` |
| `pbpaste` | Pegar contenido del portapapeles | ✅ seguro | `pbpaste` |
| `proj` | Seleccionar un proyecto | 🔴 mutación | `proj` |
| `rgaf` | Buscar contenido (PDF/docs) con ripgrep-all | ✅ seguro | `rgaf test` |
| `take` | Crear directorio y entrar | 🔴 mutación | `take carpeta` |
| `tproj` | Abrir proyecto en tmux | ✅ seguro | `tproj` |
| `y` | Abrir Yazi | 🔴 mutación | `y` |
| `z` | Cambiar directorio con zoxide | 🔴 mutación | `z proyecto` |

## Sistema

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `fkill` | Finalizar un proceso seleccionado | 🔴 mutación | `fkill` |
| `path` | Mostrar PATH por entradas | ✅ seguro | `path` |
| `ports` | Mostrar puertos en escucha | ✅ seguro | `ports` |
| `reload` | Recargar Bash | 🔴 mutación | `reload` |
| `topme` | Mostrar procesos del usuario | ✅ seguro | `topme` |
| `trash` | Mover archivos a la papelera | 🔴 mutación | `trash archivo` |
| `ts` | Gestionar una sesión tmux | ✅ seguro | `ts` |
| `tt` | Abrir terminal auxiliar | ✅ seguro | `tt` |

## Utilidad

| Comando | Descripción | Riesgo | Ejemplo |
| --- | --- | --- | --- |
| `bench` | Medir tiempo de un comando | ✅ seguro | `bench comando` |
| `blib-help` | Buscar ayuda Bash con fzf | ✅ seguro | `blib-help` |
| `cat` | Mostrar archivos con paginación ligera | ✅ seguro | `cat archivo` |
| `cls` | Limpiar la pantalla | ✅ seguro | `cls` |
| `dotfiles_excludes_nul` | Obtener exclusiones de dotfiles | ✅ seguro | `dotfiles_excludes_nul` |
| `dothelp` | Listar ayuda de comandos Bash | ✅ seguro | `dothelp` |
| `envswap` | Activar un entorno .env con backup | ⚠ confirmación | `envswap use staging` |
| `fhist` | Buscar en el historial | ✅ seguro | `fhist` |
| `grep` | Buscar texto con color | ✅ seguro | `grep patrón` |
| `n` | Abrir Neovim | ✅ seguro | `n` |
| `rgf` | Buscar y abrir resultados con fzf | ✅ seguro | `rgf patrón` |
| `rgrep` | Buscar con ripgrep y color | ✅ seguro | `rgrep patrón` |
| `todo` | Gestionar tareas pendientes | 🔴 mutación | `todo` |
| `vim` | Abrir Neovim | ✅ seguro | `vim archivo` |

