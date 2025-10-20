# Bootstrap, Backups & Rollback

## Requisitos
- GNU stow (`sudo pacman -S stow`)

## Bootstrap (dry-run)
```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh --dry-run
```

## Bootstrap (aplicar)
```bash
bash ./scripts/bootstrap.sh
```
Crea `./.backups/<TS>/` y `./.manifests/<TS>.manifest` y enlaza:
- Bash/Git/Tmux/Vim ⇒ $HOME
- Paquetes `config/*` ⇒ `~/.config` (stow)

## Rollback (último)
```bash
bash ./scripts/rollback.sh latest
```
O por timestamp:
```bash
bash ./scripts/rollback.sh 20251020-120000
```

## Modo alternativo: git bare
Documentado en `bootstrap.sh --mode=bare` (no se ejecuta por defecto).
