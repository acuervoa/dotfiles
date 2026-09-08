# PERS-GUI

## 1. Goal

PERS-GUI define una Desktop Integration Layer mínima sobre Arch Linux, X11,
LightDM e i3wm, sin instalar un Desktop Environment completo.

Principio operativo: cuando se sale de Bash/Tmux/Neovim, el sistema debe seguir
siendo predecible, rápido, coherente y controlable.

## 2. Platform

```text
Display manager: LightDM
Window manager: i3
Display protocol: X11
Desktop environment: none
DISPLAY=:0
XDG_SESSION_TYPE=x11
```

`DESKTOP_SESSION`, `XDG_CURRENT_DESKTOP` y `XDG_SESSION_DESKTOP` pueden estar
vacías sin constituir un fallo por sí mismas.

## 3. Architecture

```text
dotfiles
    ↓
GNU Stow / apply
    ↓
~/.config + ~/.local/share
    ↓
PERS-GUI runtime

PERS-LAB
    ↓
repos-local-state
    ↓
dotfiles + pers-lab-backup
```

## 4. Ownership model

| Categoría | Owner | Tratamiento |
|---|---|---|
| `DOTFILES` | `/home/acuervo/dotfiles` | Configuración reproducible de usuario y PERS-GUI |
| `PERS_LAB_PRIVATE_BACKUP` | PERS-LAB | Estado privado/no versionable |
| `PACKAGE_OWNED` | pacman | `/usr/share`, `/usr/lib` y runtime proporcionado por paquetes |
| `RUNTIME_REGENERATED` | sistema | sockets, unidades generadas y estado efímero |
| `POLICY_NEGATIVE_STATE` | dotfiles apply/check | Estado que debe estar ausente |

```text
~/.config/autostart/Nextcloud.desktop
→ MUST NOT EXIST
→ política propiedad de dotfiles apply/check
```

## 5. GUI status matrix

| Contract | Estado |
|---|---|
| GUI-01 session integration | `CLOSED` |
| GUI-02 MIME/default applications | `CLOSED` |
| GUI-03 file chooser/open-save-upload | `CLOSED` |
| GUI-04 trash | `CLOSED` |
| GUI-05 devices/mounts core | `CLOSED` |
| GUI-06 notifications | `CLOSED` |
| GUI-07 Polkit runtime | `CLOSED` |
| GUI-08 thumbnailing | `CLOSED` |
| GUI-09 clipboard | `CLOSED` |
| GUI-10 autostart/lifecycle | `CLOSED` |
| GUI-11 FileManager1/reveal-in-folder | `CLOSED` |
| GUI-12 terminal integration | `CLOSED` |
| GUI-13 screenshots | `CLOSED` |
| GUI-14 power/session actions | `CLOSED` |
| GUI-15 Secret Service | `CLOSED` |
| GUI-16 idle/DPMS | `DEFERRED_BY_POLICY` |

Pendientes naturales, no bugs: GUI-05D unmanaged removable media, GUI-07F
Polkit en el siguiente login natural, GUI-10G Nextcloud en el siguiente login
natural y GUI-16 en modo `MANUAL_ONLY`.

## 6. Session integration

`i3-session.target` se integra con `graphical-session.target` bajo
`systemd --user` y arranca `clipmenud.service`. `session-start.sh` importa el
entorno de sesión y activa el target. La deuda de entorno stale de tmux es
separada y no cambia este contrato funcional.

## 7. MIME/default applications

```text
inode/directory          thunar.desktop
text/plain               nvim-kitty.desktop
application/pdf          org.pwmt.zathura.desktop
image/png                feh.desktop
video/mp4                mpv.desktop
audio/mpeg               mpv.desktop
application/zip          xarchiver.desktop
text/html                firefox.desktop
x-scheme-handler/http    firefox.desktop
x-scheme-handler/https   firefox.desktop
x-scheme-handler/mailto  firefox.desktop
```

## 8. File chooser / portals

Firefox y Brave usan diálogos nativos. Ferdium Flatpak usa:

```text
org.freedesktop.portal.FileChooser
    → xdg-desktop-portal
    → xdg-desktop-portal-gtk
    → GTK chooser
```

## 9. Trash / GVFS

La integración de papelera usa `gvfs`, `gvfsd`, `gvfsd-fuse` y `gvfsd-trash`.
Los contratos trash/restore están `PASS`.

## 10. Devices / mounts

`/mnt/Elements` y `/mnt/HANYDRIVE` son gestionados por `/etc/fstab` y unidades
`.automount` de systemd. Que no aparezcan como desktop volumes es deliberado.

## 11. Notifications

`dunst` mantiene una sola instancia y proporciona
`org.freedesktop.Notifications`. Las notificaciones por portal también
terminan en este backend.

## 12. Polkit

```text
agent: /usr/bin/lxqt-policykit-agent
owner: i3
instances: 1
```

El prompt gráfico de `pkexec` está certificado como `PASS`.

## 13. Thumbnailing

```text
thunar
    → tumbler
    → ffmpegthumbnailer / poppler-glib
```

Contratos certificados: PNG, JPEG, PDF y vídeo. RAW, EPUB y ODF son
capacidades opcionales y no forman parte del manifest requerido.

## 14. Clipboard

La política usa el clipboard X11 y `PRIMARY`, con `xclip`, `clipmenu` y una
sola instancia de `clipmenud`.

## 15. Autostart/lifecycle

Nextcloud pertenece al lifecycle de i3 y se mantiene en una sola instancia.
Su override D-Bus es:

```ini
[D-BUS Service]
Name=com.nextcloudgmbh.Nextcloud
Exec=/usr/bin/false
```

La entrada `~/.config/autostart/Nextcloud.desktop` debe permanecer ausente.

## 16. FileManager1

`org.freedesktop.FileManager1` pertenece a Thunar. `ShowItems()` permite
revelar el target seleccionado en el gestor de archivos.

## 17. Terminal integration

```text
i3 terminal   → kitty
Rofi terminal → kitty
```

## 18. Screenshots

Bindings:

```text
$mod+F2       select
$mod+Shift+F2 full
$mod+Shift+F3 save-select
$mod+Shift+F4 delay 2 select
```

Backend: `~/.config/i3/scripts/screenshot_maim.sh`.

Contratos: captura completa, selección de región, selección guardada,
selección con retardo, PNG al clipboard y guardado a fichero.

## 19. Power/session

El backend es `~/.config/i3/scripts/i3exit.sh`:

```text
lock
logout
suspend
reboot
shutdown
```

`logout` usa `session-exit.sh`; `suspend` bloquea antes de ejecutar
`systemctl suspend`. Hibernate está deliberadamente ausente. Los incidentes
históricos de Radeon/Kitty no se reabren sin una nueva reproducción.

## 20. Secret Service

`gnome-keyring-daemon` proporciona los componentes `pkcs11,secrets`, con
`org.freedesktop.secrets` en una sola instancia y lifecycle propiedad de
`systemd --user`.

## 21. Idle / DPMS

```text
AUTO_LOCK=NO
DPMS=NO
AUTO_SUSPEND=NO
HIBERNATE=NO
MANUAL_LOCK=PASS
LOCK_BEFORE_SUSPEND=PASS
screensaver timeout=0
DPMS disabled
```

Este estado es `DEFERRED_BY_POLICY`, no un gap.

## 22. Dotfiles integration

```text
DOTFILES_REPO=/home/acuervo/dotfiles
METHOD=GNU Stow
```

Los artefactos relevantes son los paquetes i3 y rofi, `mimeapps.list`, la
configuración systemd de usuario, el override D-Bus de Nextcloud, los scripts
GUI, la política negativa y `scripts/check-desktop-configs.sh`.

`apply/bootstrap` puede cambiar estado. `check` es estrictamente de sólo
lectura.

## 23. Package manifest

El contrato requerido vive en
`manifests/pers-gui-packages.txt`: 26 paquetes Arch, sin versiones fijadas.
La lista no se duplica aquí para evitar divergencias.

```text
pkglist-arch.txt
    → perfil general host/core-GUI
manifests/pers-gui-packages.txt
    → dependencias funcionales REQUIRED_CORE de PERS-GUI
/home/acuervo/bin/backup-lab/pers-lab-packages.txt
    → PERS-LAB only
```

El proveedor instalado de picom es `picom-ftlabs-git`.

## 24. Package installation policy

```text
PACKAGE_INSTALLATION=EXPLICIT
BOOTSTRAP_AUTO_INSTALL=NO
INSTALL_OWNER=scripts/install_deps.sh
```

`bootstrap.sh` nunca ejecuta `sudo pacman` implícitamente. La instalación
futura debe ser explícita y reutilizar `scripts/install_deps.sh`.

## 25. PERS-LAB relationship

```text
PERS_LAB_REPO=/home/acuervo/bin/backup-lab
```

`repos-local-state` protege estos siete repos:

```text
Biorrhythms
imapGmail
imapGmail-dashboard
newsletter-reader
pers-lab-home
dotfiles
pers-lab-backup
```

El formato es `repo.bundle`, `tracked.patch`, `untracked/` y `manifest.ok`,
que contiene la sección SHA256.

## 26. Restore flow

```text
restore bootstrap host
    → restore dotfiles repo
    → restore pers-lab-backup repo
    → install PERS-GUI packages explícitamente
    → apply Stow
    → apply negative policies
    → systemd user daemon-reload si procede
    → ejecutar verificación read-only
```

El restore de dotfiles no mezcla secretos, keyrings ni estado runtime. Los
dominios de secretos/host-private se restauran separadamente desde PERS-LAB.

## 27. Verification

Comando canónico:

```bash
scripts/check-desktop-configs.sh --static
```

Valida archivos y symlinks de PERS-GUI, sintaxis shell, MIME, el override
D-Bus y la política negativa de Nextcloud, unidades systemd de usuario,
contratos de power/session, disponibilidad de los 26 paquetes y ausencia de
duplicados en el manifest.

## 28. Rollback

El rollback primario es Git mediante `git revert`.

Commits relevantes:

```text
dotfiles:
d3b99ca  feat(gui): consolidate desktop integration layer
d8a7b96  feat(gui): add reproducible package manifest

PERS-LAB:
f36a3df  chore: establish PERS-LAB backup and DR source baseline
1b8ef16  chore(dr): retire committed dotfiles untracked allowlist
34f1c24  feat(dr): protect PERS-LAB backup source state
```

Los backups manuales sólo son recuperación excepcional y no source of truth.

## 29. Wayland migration boundary

Mayormente reutilizable:

```text
MIME, Thunar, GVFS, Trash, portals, Secret Service, D-Bus contracts,
package ownership, dotfiles, PERS-LAB DR y conceptos systemd-user lifecycle
```

Específico de X11 o probablemente reemplazable:

```text
i3, i3lock, maim, integración X11 de clipmenu, xclip,
DISPLAY/XAUTHORITY glue y picom
```

La migración Wayland es un proyecto futuro separado.

## 30. Maintenance mode

```text
PERS-GUI=MAINTENANCE_MODE
```

Se abre trabajo nuevo sólo ante una regresión observable, un requisito
funcional nuevo o un cambio explícito de política. No se buscan subsistemas
adicionales indefinidamente.
