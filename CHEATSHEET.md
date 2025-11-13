# Neovim · tmux · i3 — Atajos unificados

## Navegación de paneles / ventanas
- (nvim/tmux) Mover foco: `<C-h> <C-j> <C-k> <C-l>`
- (nvim)      Ventanas: `<leader>"` (split), `<leader>%` (vsplit), `<leader><BS>` (only), `<leader>q` (close)
- (tmux)      Zoom pane: `Z`   ·  Sync panes: `F10` (prefijo o passthrough si estás en nvim)
- (i3)        Foco: `$mod+h/j/k/l`  ·  Fullscreen: `$mod+z`

## Buffers y archivos
- Buffers: `H` (prev), `L` (next), `<C-^>` (alterno), `<leader>s` (`:ls` → `:b`)
- Explorador: `<C-b>` (toggle Neo-tree), `<leader>e` (focus)
- Cerrar vistas auxiliares: `q` (help, quickfix, outline, etc.)

## Búsqueda y navegación
- Búsqueda: `<C-f>` (NORMAL) → `/`  ·  Alias: `<leader>/`
- Diagnóstico LSP: `<leader>cd` (bubble), `[d` / `]d` (prev/next)
- Trouble: `<leader>xx` (workspace), `<leader>xd` (buffer), `<leader>xq` (quickfix)

## Edición rápida
- Comentarios: `<C-_->` (línea/visual)  ·  Surround: `cs`, `ds`, `ys{motion}`
- Mover/duplicar líneas: `<A-j>/<A-k>` · Duplicar: `<S-A-j>/<S-A-k>`
- Selección sintáctica (TS): Expandir `<leader><CR>` · Reducir `<BS>`
- Toggle: `<leader>tw` (wrap), `<leader>tn` (relativenumber), `<leader>ts` (spell es/en)
- Formato: `<leader>cf` (Conform) · `:FormatToggle` (auto on-save)

## LSP / DAP
- Go to: `gd`, `gD`, `gi`, `gt`, `K` (hover), `<F2>` (rename)
- DAP: `<F5>` (continue), `<F9>` (breakpoint), `<F10>/<F11>/<S-F11>` (step)
- DAP sin F-keys (tmux): `<leader>dc` (continue), `db` (toggle bp), `dO/dI/dU` (step over/into/out), `du` (UI)

## Terminal
- ToggleTerm: `<leader>\`` o `<C-\`>` (mapeo propio del plugin)


