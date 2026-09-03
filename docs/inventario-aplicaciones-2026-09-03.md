# Inventario de aplicaciones instaladas — 2026-09-03

Fuente: `pacman -Qe` (313 paquetes explícitos, incluye 21 AUR vía yay) + `flatpak list` (1 app). Ver `TOOLS.md` para la tabla oficial de ownership por capacidad (launcher, prompt, editor, etc.) — este documento es el inventario completo, TOOLS.md es el subconjunto curado que ya vive en stow/.

Leyenda workflow: 🔗 stow-managed (config versionada) · ⚙️ usado a diario sin dotfile propio · 🧰 herramienta de soporte/ocasional · 💤 instalado, uso no confirmado.

## 1. Shell, terminal, prompt

| App | Qué hace | Workflow |
|---|---|---|
| bash, bash-completion | shell principal | 🔗 `stow/bash` |
| blesh-git | line editing avanzado en bash | 🔗 `stow/blesh` |
| atuin | historial de shell sincronizado/buscable | 🔗 `stow/atuin` |
| starship (no en Qe pero referenciado en TOOLS.md) | prompt | 🔗 `stow/starship` |
| kitty | terminal GPU | 🔗 `stow/kitty` |
| alacritty, xterm | terminales alternativas | 💤 |
| tmux, tmuxp | multiplexor de sesiones + gestor de layouts | 🔗 `stow/tmux` |
| direnv | entorno por proyecto | 🔗 `stow/bash` |
| mise | gestor de versiones de runtime — owner único (node, php; python/rust vía sistema/rustup) | 🔗 `stow/mise` |
| rustup | toolchains rust (stable/beta/nightly) — capacidad que mise no cubre | ⚙️ `~/.cargo/env` en `.profile` |
| zoxide | `cd` inteligente | 🔗 `stow/bash` |
| fzf | fuzzy finder para historial/archivos | 🔗 `stow/bash` |
| navi | cheatsheet interactivo | ⚙️ |
| tealdeer (tldr) | man pages resumidas | ⚙️ |

## 2. Escritorio / WM / input

| App | Qué hace | Workflow |
|---|---|---|
| i3-wm, i3blocks, i3lock, i3status | window manager principal + barra/lock | 🔗 `stow/i3` — owner de "windows" |
| ~~niri, xwayland-satellite~~ | eliminados 2026-09-03: decisión tomada, i3 gana | — |
| rofi | launcher | 🔗 `stow/rofi` — owner de "launcher" |
| ~~albert~~ | eliminado 2026-09-03: autoarrancaba sin keybind, launcher real es rofi (4 binds activos) | — |
| polybar | barra de estado | 🔗 `stow/polybar` — owner "persistent status" |
| dunst | notificaciones | 🔗 `stow/dunst` — owner "notifications" |
| picom-ftlabs-git | compositor (blur, sombras) | 🔗 `stow/picom` |
| lightdm, lightdm-gtk-greeter, lightdm-settings | display manager / login | ⚙️ |
| clipmenu | historial de portapapeles — owner "clipboard-history" | 🔗 `$mod+v`, `clipmenud.service` |
| ~~copyq, cliphist~~ | eliminados 2026-09-03: copyq corría monitoreando clipboard sin keybind ni ref; cliphist no corría ni tenía refs | — |
| xbindkeys, numlockx, autorandr | atajos globales, multi-monitor | ⚙️ |
| network-manager-applet, networkmanager | red gráfica | ⚙️ |
| feh | visor de imágenes / wallpaper | ⚙️ |
| flameshot (via stow, no listado en Qe directo) | capturas de pantalla | 🔗 `stow/flameshot` |
| maim, slop | captura de pantalla scriptable | 🧰 |
| redshift | filtro de luz azul | ⚙️ |
| gnome-themes-extra, materia-gtk-theme, papirus-icon-theme | temas GTK | 🔗 `stow/gtk-3.0`, `stow/gtk-4.0` |
| ~~dms-shell, dms-shell-niri~~ | eliminados 2026-09-03: dependían del stack niri, ya descartado | — |
| ~~dms-shell-hyprland, hyprland~~ | eliminados 2026-09-03: sin `~/.config/hypr`, nunca configurado, arrastraba hyprland entero como dependencia oculta (no explícita, no salía en `pacman -Qe`) | — |
| nextcloud-client | sync de archivos — cuenta reconfigurada en `nextcloud.andrescuervo.info` (la guardada apuntaba a un servidor viejo, `mia.nl.tab.digital`) | 🔗 `stow/Nextcloud`, autostart reactivado |
| ~~fabric, matugen~~ | eliminados 2026-09-03: sin uso en el stack i3 (polybar/rofi/dunst no los referencian), eran parte de la prueba de niri/dms-shell | — |

## 3. Editor / desarrollo

| App | Qué hace | Workflow |
|---|---|---|
| neovim | editor principal — owner "editor" | 🔗 `stow/nvim` |
| visual-studio-code-bin | editor secundario | 🔗 `stow/code` |
| micro | editor de respaldo/rápido | 🧰 |
| lua-language-server, gopls (go bin), rust-analyzer (cargo) | LSPs | 🔗 usados por nvim |
| tree-sitter-cli, ctags | parsing/indexado de símbolos | 🧰 soporte de nvim |
| ninja, go, julia, php, php-build, jre-openjdk, tk, lua51, luarocks | runtimes/toolchains de lenguaje | ⚙️ según proyecto |
| yarn, npm (via node) | gestores de paquetes JS | ⚙️ |
| uv, python-pip, python-pipx | gestores de paquetes Python | ⚙️ |
| prettier, shellcheck, shfmt, python-flake8 | linters/formatters | 🧰 |
| lldb, strace, ltrace, gdb (rust-gdb) | debugging de bajo nivel | 🧰 |
| dbeaver, pgcli, sqlitebrowser | clientes de base de datos | ⚙️ |
| docker, docker-buildx, docker-compose, lazydocker-bin | contenedores + TUI | ⚙️ |
| kubectl, k9s, kind | Kubernetes local + TUI | ⚙️ |
| ddev-bin, ddev-bin-debug | entorno de desarrollo web dockerizado (PHP/Drupal/etc.) | ⚙️ |
| git, github-cli, lazygit, git-delta, difftastic, git-filter-repo, mercurial | control de versiones — LazyGit owner "git-visual", delta owner de diff pager | 🔗 `stow/git`, `stow/lazygit`, `stow/gh-dash` |
| ~~gitflow-cjs~~ | eliminado 2026-09-03: cero uso de `git flow` en historial | — |
| ollama | LLMs locales | ⚙️ |
| openai-codex | CLI de agente de código — uso indistinto junto a Claude Code (y cliente de Antigravity/Gemini), no compiten, decisión consciente | ⚙️ |
| playwright (bin + npm) | automatización de navegador para tests | ⚙️ |
| asciinema, asciinema-agg | grabación de terminal | 🧰 |
| glow, mdcat, bat | render de markdown/código en terminal | ⚙️ |

## 4. CLI utils generales (reemplazos modernos + soporte)

| App | Qué hace | Workflow |
|---|---|---|
| ripgrep (rg), fd, fzf | búsqueda de texto/archivos | ⚙️ base de navegación |
| eza, tree, dust, duf | listar archivos/disco (reemplazos de ls/du/df) | ⚙️ |
| bat, most, less, multitail, lnav | paginadores y análisis de logs (lnav owner "log analysis") | 🔗 `stow/lnav` |
| jq, xh, difftastic | JSON, HTTP client, diffs estructurales | ⚙️ |
| yazi, ranger | navegadores de archivos TUI (yazi owner "filesystem navigation") | 🔗 `stow/yazi` |
| btop, htop, iotop, bandwhich, procs, gping | monitoreo de sistema/red — btop owner "system monitoring", bandwhich owner "network by process" | 🔗 `stow/btop` |
| trash-cli | rm seguro con papelera | ⚙️ |
| moreutils, parallel, patchutils | utilidades Unix extendidas | 🧰 |
| tealdeer, navi, figlet, boxes, lolcat, cava | utilidades cosméticas/cheatsheets | 🧰 |
| chafa, fim, ueberzugpp, ffmpegthumbnailer | previsualización de imágenes en terminal | 🧰 soporte de yazi |
| task, taskwarrior-tui-git | gestión de tareas CLI | 💤 |
| zathura + plugins (cb, djvu, pdf-mupdf, ps) | visor de PDF/comics minimalista | ⚙️ |

## 5. Redes, seguridad, pentesting

| App | Qué hace | Workflow |
|---|---|---|
| nmap, gobuster, ffuf, nikto | escaneo/enumeración — pentesting autorizado | 🧰 |
| ~~reaver, kismet~~ | eliminados 2026-09-03: última captura real mayo 2025, sin servicio activo, cero historial reciente | — |
| tcpdump, termshark, sniffnet, ifstat, mtr, bind (dig) | captura y diagnóstico de tráfico/DNS | 🧰 |
| ~~dog~~ | eliminado 2026-09-03: bind ya provee dig en un único paquete de 7MB, sin versión "solo cliente" separada en Arch actual | — |
| ~~nethogs, iftop~~ | eliminados 2026-09-03: overlap con bandwhich/sniffnet, sin alias ni uso registrado | — |
| ufw, firejail, usbguard | firewall, sandboxing, control USB | ⚙️ hardening |
| tor, openvpn, easy-rsa, dnscrypt-proxy | privacidad/VPN/DNS cifrado | ⚙️ |
| pass | gestor de contraseñas CLI (GPG) | ⚙️ |
| Bitwarden (extensión navegador, no pacman) | autofill/gestor de contraseñas en firefox/brave/chromium | ⚙️ fuera del alcance de este inventario (no es paquete de sistema) |
| bitwarden-cli (`bw`) | CLI oficial, login vía API key (client_id/secret) | 🔗 `stow/bin` (`rofi-bw`), owner "clipboard-password" |
| ~~rbw, rofi-rbw~~ | probados y eliminados 2026-09-03: la cuenta requiere "new device verification" (Bitwarden), no soportado por rbw 1.15.0. Reemplazados por script propio `rofi-bw` (bw + jq + rofi + xclip) en `$mod+p` | — |
| lynis, arch-audit | auditoría de seguridad del sistema | 🧰 — ver `docs/security-hardening.md` |
| sniffnet | monitor visual de tráfico de red | 🧰 |
| gitleaks (referenciado en TOOLS.md) | escaneo de secretos en commits | 🔗 `scripts/check-secrets.sh` |
| samba, filezilla, lftp, rclone, rclone-browser | transferencia de archivos / shares | ⚙️ `stow/rclone` |
| certbot | certificados TLS | 🧰 |

## 6. Sistema, mantenimiento, hardware

| App | Qué hace | Workflow |
|---|---|---|
| pacman-contrib, reflector, downgrade, etc-update | mantenimiento de pacman/mirrors | 🧰 ver `docs/status.md` |
| chaotic-keyring, chaotic-mirrorlist, yay | repo AUR extra + AUR helper | ⚙️ |
| systemd-resolvconf, upower, fwupd, smartmontools | servicios base, batería, firmware, SMART | ⚙️ |
| tlp | gestión de energía laptop | ⚙️ |
| ananicy | prioridades de proceso automáticas | ⚙️ |
| radeontop, mesa-utils, vulkan-tools, glmark2 | diagnóstico GPU AMD (relevante — ver memoria GPU fix) | 🧰 |
| brightnessctl, pamixer, alsa-utils, pulseaudio(+alsa) | brillo y audio | ⚙️ |
| bluez, bluez-utils | Bluetooth | ⚙️ |
| efibootmgr, grub, dosfstools, exfatprogs, ntfs-3g, ntfsprogs, fuse3, mtpfs, simple-mtpfs | boot y sistemas de archivos removibles | 🧰 |
| android-tools | adb/fastboot | 🧰 |
| geoclue | geolocalización | 💤 |
| fastfetch | resumen de sistema en terminal | ⚙️ |

## 7. Ofimática, documentos, medios

| App | Qué hace | Workflow |
|---|---|---|
| libreoffice-fresh (+ es) | suite ofimática | ⚙️ |
| calibre | gestor/lector de ebooks | 💤 |
| obsidian | notas — vault "SimpleBrain" (roadmap Linux) | 🔗 `stow/obsidian` |
| poppler, djvulibre, odt2txt, perl-image-exiftool | conversión/extracción de metadatos de documentos | 🧰 |
| imagemagick, gimp, python-pillow | edición/procesamiento de imágenes | ⚙️ |
| vlc + vlc-plugin-ffmpeg, mediainfo | reproducción y metadatos de video | ⚙️ |
| ffmpegthumbnailer | miniaturas de video (soporte yazi) | 🧰 |

## 8. Comunicación / navegadores / entretenimiento

| App | Qué hace | Workflow |
|---|---|---|
| firefox, brave-bin, chromium | navegadores | ⚙️ |
| ~~telegram-desktop, zapzap~~ | eliminados 2026-09-03: consolidado en Ferdium (ya tenía ambos servicios configurados) | — |
| weechat | IRC | ⚙️ |
| newsflash | lector RSS | 💤 |
| freetube | YouTube sin tracking | 💤 |
| spotify | música | ⚙️ |
| **Ferdium** (Flatpak) | agregador multi-servicio de mensajería — owner único de WhatsApp+Telegram desde 2026-09-03 | ⚙️ único flatpak instalado |
| steam, lutris, wine (+gecko/mono), winetricks, gamemode, lib32-gamemode, lib32-mesa, lib32-alsa-plugins | gaming / compatibilidad Windows | 💤 |

## 9. Backup

| App | Qué hace | Workflow |
|---|---|---|
| restic | backup incremental cifrado de `$HOME` → `/mnt/Elements/restic-backup`, dedup por chunk | 🔗 `stow/restic`, `stow/systemd` (`restic-backup.timer`, semanal), `stow/bin` (`restic-backup.sh`) |

Retención: 8 semanales / 12 mensuales / 2 anuales (`restic forget --prune`). Password fuera del repo en `~/.config/restic/password` (no versionado, por diseño). Excludes en `stow/restic/.config/restic/excludes.txt`, derivado de `docs/backup-excludes.txt` + caches genéricos de dev.

| simplescreenrecorder-git | grabador de pantalla de vídeo (X11/OpenGL) — gap cerrado 2026-09-03 | ⚙️ manual vía rofi drun (`.desktop` propio) |

## Resumen

- **2026-09-03 update:** eliminados 3 duplicados obvios — `exiftool-rs-git` (queda `perl-image-exiftool`), `vim` (queda `neovim`), `httpie` (queda `xh`). Ninguno tenía reverse-deps ni refs de uso real en dotfiles.
- **2026-09-03 update 2:** version managers consolidados en mise — eliminados `fnm`, `pyenv`, `pyenv-virtualenv`, `asdf-vm` (ninguno estaba sourced en `.bashrc` salvo fnm, que perdía igual contra `/usr/bin/node` del sistema). Sacado bloque `fnm` de `stow/bash/.bashrc`, `node` instalado vía `mise install node` (24.20.0 lts). `rustup` se mantiene — gestiona canales stable/beta/nightly, capacidad fuera del alcance de mise. Nota: `/usr/bin/node` (paquete `nodejs-lts-jod`, dependencia de `npm`/`prettier`/`playwright`/`yarn`) sigue ganando en PATH global fuera de directorios con `.mise.toml` — comportamiento normal de mise (activa por directorio), no bug.
- **2026-09-03 update 3:** matados overlaps de escritorio/red — `albert` (launcher sin keybind, rofi es el real), `copyq`+`cliphist` (clipmenu es el real), `nethogs`+`iftop` (overlap con bandwhich/sniffnet). Instalado `restic` — repo iniciado en `/mnt/Elements`, backup diario vía `restic-backup.timer` (systemd --user), primer snapshot completo corrido y verificado.
- Núcleo del workflow diario (🔗, stow-managed): shell (bash+atuin+blesh+starship+zoxide+fzf), terminal (kitty), WM (i3+rofi+polybar+dunst+picom), editor (nvim, + code secundario), git (lazygit+delta+gh-dash), clipboard (clipmenu), file nav (yazi), monitoring (btop), logs (lnav), versiones (mise), backup (restic) — todo documentado y con ownership único en `TOOLS.md`.
- **2026-09-03 update 4:** `dms-shell-hyprland` + `hyprland` (dependencia oculta, nunca configurada) fuera. `nextcloud-client` reinstalado — la cuenta guardada apuntaba a un servidor viejo (`mia.nl.tab.digital`), reconfigurada a `nextcloud.andrescuervo.info`.
- **2026-09-03 update 5:** revisados overlaps menores. delta+difftastic y glow+mdcat: falsos positivos, ambos con uso real distinto (delta/difftastic por decisión consciente documentada; glow de uso manual fuera de dotfiles). dog vs bind(dig): sin resolver, ninguno con uso confirmado, bind se queda por ahora. Mensajería consolidada en Ferdium — `telegram-desktop` y `zapzap` fuera (Ferdium ya tenía ambos servicios configurados).
- 313 → 298 paquetes explícitos pacman (292 repo oficial/chaotic-aur + 21 AUR − removidos, +1 nextcloud-client), 1 app Flatpak (Ferdium).
- **2026-09-03 update 6:** revisados los 💤 dudosos. `kismet`+`reaver` fuera (última captura real mayo 2025, sin uso desde entonces), `opencollada` fuera (instalado explícito pero sin Blender/proyecto 3D ni historial — prueba puntual olvidada), `gitflow-cjs` fuera (cero uso de `git flow`). `julia` se queda — usado ayer (2026-09-02), `~/.julia` con contenido real de juliaup.
- **2026-09-03 update 7:** limpieza de huérfanos (`pacman -Qtdq`) tras todas las bajas del día — 22 paquetes sin dueño (`ada`, `bluez-libs`, `ddev-bin-debug`, `electron39`, `kcoreaddons`, `knotifications`, `kstatusnotifieritem`, `libjcat`, `libwebsockets`, `meson`, `miniaudio`, `mosquitto`, `protobuf-c`, `python-multidict`, `python-pydantic`, `python-sgmllib3k`, `qca-qt6`, `qcoro`, `rnnoise`, `rtl-sdr`, `svt-hevc`, `vim-runtime`) fuera con `-Rns`. Ninguno con servicio activo ni reverse-deps.
- 313 → 296 paquetes explícitos pacman (verificado con `pacman -Qe | wc -l`).
- **2026-09-03 update 8:** dog vs bind(dig) resuelto — `dog` fuera, `bind` se queda (ya es paquete unificado en Arch, solo 7MB, no existe versión "solo cliente" separada).
- 296 → 295 paquetes explícitos pacman.
- **2026-09-03 update 9:** decisión tomada — i3 gana sobre niri/dms-shell. Fuera todo el stack de evaluación: `niri`, `xwayland-satellite`, `dms-shell`, `dms-shell-niri`, `fabric`, `matugen`. Config local de niri (`~/.config/niri`) borrada.
- **2026-09-03 update 10:** openai-codex vs Claude Code — no era fricción real, es uso consciente en paralelo (junto a cliente de Antigravity/Gemini). Sin cambios, cerrado.
- 295 → 289 paquetes explícitos pacman.
- **2026-09-03 update 11:** cerrado el gap de autofill de contraseñas — Bitwarden ya cubría navegador, faltaba terminal. Probado `rbw`+`rofi-rbw` (bloqueado por "new device verification" no soportado), reemplazado por `bitwarden-cli` (`bw`, login por API key) + script propio `stow/bin/.local/bin/rofi-bw` en `$mod+p`. `rbw`/`rofi-rbw` fuera.
- 296 → 290 paquetes explícitos pacman (verificado con `pacman -Qe | wc -l`).
- **2026-09-03 update 12:** cerrado el último gap — `simplescreenrecorder-git` instalado (grabador de pantalla, X11). Arranque manual vía rofi drun, sin keybind dedicado.
- 290 → 291 paquetes explícitos pacman.
- Sin gaps ni fricciones abiertas pendientes de decisión — todo lo identificado en esta sesión quedó resuelto (removido, consolidado, instalado, o confirmado como intencional).
- Lección del proceso: `pacman -Qe` solo lista explícitos — una dependencia "oculta" como hyprland (pull de dms-shell-hyprland) no aparece ahí. Para detectar peso muerto real hace falta cruzar con `Motivo de la instalación` (`pacman -Qi <pkg> | grep Motivo`), no solo con la lista explícita.
- Pentesting/red (ffuf, gobuster, nikto, nmap) instalados pero sin integración a scripts propios — uso manual puntual, no automatizado en dotfiles.

---
Generado a mano a partir de `pacman -Qe` + `flatpak list`, cruzado con `stow/` y `TOOLS.md` del repo dotfiles. No autogenerado — actualizar manualmente o promover a script si el inventario se vuelve rutina.
