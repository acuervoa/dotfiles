# Diseño: PATH determinista y perfiles Bash

## Objetivo

Eliminar duplicaciones y drift del `PATH` entre shells login, no-login,
interactivas y recargas, manteniendo la precedencia útil para herramientas del
usuario y sin exponer secretos del fichero local.

## Contrato de precedencia

El orden estático deseado será:

1. `$HOME/.local/bin`.
2. `$HOME/bin`.
3. `$HOME/.bun/bin`.
4. `$HOME/.opencode/bin`.
5. `$HOME/.local/share/composer/vendor/bin`.
6. PATH heredado y rutas añadidas por Cargo, Juliaup, fnm, mise, Nix y el
   sistema.

La primera aparición de cada ruta gana. Las entradas vacías y duplicadas se
eliminan sin alterar el orden relativo de las restantes.

## Ownership de ficheros

- `.profile`: entorno POSIX y PATH estático; carga Cargo y conserva
  `PROJECTS_ROOT`.
- `.bash_profile`: sólo carga `.profile` y `.bashrc`; no repite PATH, Juliaup ni
  Bun.
- `.bashrc`: integraciones interactivas, gestores dinámicos y normalización
  final del PATH después de `.bashrc_local`.
- `.bashrc_local`: override privado del usuario; no se versiona, no se lee para
  generar documentación y no se modifica durante esta fase.

Juliaup conservará su guardado de completado en el contexto interactivo y una
sola inicialización de PATH. Bun, OpenCode, Composer y `.local/bin` tendrán un
único punto de declaración estática.

## Seguridad

- No copiar, imprimir, versionar ni modificar el contenido de `.bashrc_local`.
- Las pruebas usarán un `HOME` temporal o valores sintéticos cuando necesiten
  inspeccionar precedencia.
- No cambiar variables de credenciales ni comandos AI.

## Validación

- `bash -n` sobre todos los ficheros Bash versionados.
- Shell interactiva login y no-login: mismo conjunto de rutas estáticas, sin
  duplicados.
- Dos recargas consecutivas: PATH byte a byte estable.
- Verificar que las rutas estáticas aparecen en el orden contratado.
- Medir arranque antes/después sin exigir una mejora artificial de latencia.
- `git diff --check` y confirmación de que no cambian tmux/i3.

## Fuera de alcance

- Secretos y contenido de `.bashrc_local`.
- Renombrado de aliases o funciones.
- Atuin, ble.sh, prompt, AgentMemory, tmux e i3.

