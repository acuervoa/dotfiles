-- lua/config/env.lua
-- Fuente única de verdad sobre el entorno en el que corre Neovim.

local M = {}

local uname = vim.loop.os_uname()
local sysname = uname.sysname or ""

-- OS base
M.is_linux = sysname == "Linux"
M.is_macos = sysname == "Darwin"
M.is_windows = sysname:match("Windows") ~= nil

-- WSL detection
M.is_wsl = (vim.fn.has("wsl") == 1) or (vim.env.WSL_INTEROP ~= nil)

-- Linux "de escritorio": Linux no-WSL sin SSH
M.is_desktop_linux = M.is_linux and not M.is_wsl and not vim.env.SSH_CONNECTION

-- AWS / entornos server "remotos"
M.is_aws = (vim.env.AWS_EXECUTION_ENV ~= nil)
	or (vim.env.ECS_CONTAINER_METADATA_URI ~= nil)
	or (vim.env.NVIM_AWS == "1")

-- Headless (sin UI attach)
M.is_headless = (#vim.api.nvim_list_uis() == 0)

-- CI / pipelines
M.is_ci = vim.env.CI == "true" or vim.env.GITHUB_ACTIONS == "true"

-- Umbral bigfile en bytes (configurable por env)
local default_bigfile = 2 * 1024 * 1024 -- 2MB por defecto
local env_bigfile = tonumber(vim.env.NVIM_BIGFILE_THRESHOLD or "")
M.bigfile_threshold = env_bigfile or default_bigfile

return M
