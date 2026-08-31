# Bash AI Grammar Ownership Design

## Objetivo

Eliminar la duplicidad de definiciones de la gramática AI de Bash para que exista
un owner versionado y predecible, sin modificar tmux/i3, sin tocar secretos y sin
cambiar voluntariamente los nombres públicos ni su comportamiento observable.

## Contexto confirmado

La carga efectiva es:

1. `.bash_lib/bash_lib.sh` carga los módulos, incluido `ai.sh`.
2. `.bashrc_local`, si existe, se carga después de la librería.
3. `.bashrc` vuelve a definir parte de la gramática AI después del override local.

Por tanto, varias funciones funcionan actualmente por sobrescritura posterior y
no por ownership explícito. `~/.bashrc_local` está fuera del repositorio y puede
contener secretos; esta fase no lo leerá ni modificará en el repositorio.

## Diseño elegido

`stow/bash/.bash_lib/ai.sh` será el owner versionado de estas órdenes:

- `afs`, `afc`, `afd`, `afa`
- `af`, `afl`, `afx`
- `aflastdraft`, `afapplylast`
- `afdp`, `afdb`
- `sbclose`
- `ai`

Se eliminarán de `stow/bash/.bashrc` las copias que dupliquen funciones de
`ai.sh`. Las órdenes que sólo existen en `.bashrc` se trasladarán a `ai.sh`
antes de eliminarse de `.bashrc`, conservando sus interfaces actuales.

Las definiciones locales seguirán siendo una capa de override explícita. No se
intentará editar, sincronizar ni imprimir `~/.bashrc_local`; cualquier
personalización local existente podrá seguir prevaleciendo sobre el owner
versionado.

`aflastdraft` y `afapplylast` usarán el mismo patrón de nombre de draft dentro
del owner versionado. La ruta de la bóveda seguirá dependiendo de
`SIMPLEBRAIN_VAULT` con fallback a `$HOME/Vaults/SimpleBrain`.

## Contrato de compatibilidad

- No se renombrarán comandos públicos.
- No se modificarán bindings de tmux ni i3.
- No se cambiará la semántica de `ai end` ni `ai distill`.
- No se tocarán variables ni valores secretos.
- Recargar `.bashrc` repetidamente no debe aumentar el número de definiciones
  versionadas ni alterar el estado efectivo de los comandos.
- Si existe una definición en `.bashrc_local`, seguirá teniendo prioridad por
  ser un override local deliberado.

## Validación

Se añadirá o actualizará una prueba shell que compruebe:

1. Las funciones públicas AI existen tras cargar una shell interactiva.
2. Cada función consolidada tiene un único owner entre los módulos versionados.
3. Las definiciones se mantienen tras dos recargas consecutivas.
4. Los nombres públicos y los tipos efectivos (`alias` o `function`) no cambian.
5. La carga no imprime contenido de `.bashrc_local`.

La verificación final incluirá sintaxis Bash, la suite existente y una
comparación de `type`/`declare -F` antes y después de dos recargas.

## Fuera de alcance

- Rediseñar toda la gramática de una tecla.
- Resolver todavía la relación `r`/`redo`.
- Añadir confirmaciones a Git, Docker o Laravel.
- Crear el cheatsheet final.
- Modificar `.bashrc_local`.
- Cambiar tmux, i3 o Polybar.
