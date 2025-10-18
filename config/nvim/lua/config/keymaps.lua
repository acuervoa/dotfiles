-- Keymaps "globales" no atados a plugins concretos
local map = vim.keymap.set

-- Guardar (Ctrl+S)
map({ "n","i","v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Navegación de ventanas
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize ventanas
map("n", "<C-Up>",    "<cmd>resize +2<cr>",         { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",         { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>",{ desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",{ desc = "Increase window width" })

-- Selección/duplicado/mover líneas (tipo VSCode)
map("n","<A-j>", "<cmd>m .+1<cr>==", { desc="Move line down" })
map("n","<A-k>", "<cmd>m .-2<cr>==", { desc="Move line up" })
map("i","<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc="Move line down" })
map("i","<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc="Move line up" })
map("v","<A-j>", ":m '>+1<cr>gv=gv", { desc="Move line down" })
map("v","<A-k>", ":m '<-2<cr>gv=gv", { desc="Move line up" })
map("n","<S-A-j>", "yyp", { desc="Duplicate line down" })
map("n","<S-A-k>", "yyP", { desc="Duplicate line up" })
map("v","<S-A-j>", "y'>pgv", { desc="Duplicate selection down" })
map("v","<S-A-k>", "y'<Pgv", { desc="Duplicate selection up" })
