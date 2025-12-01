-- lua/config/env.lua
-- Detección de entorno (SO / distro / WSL / AWS, etc.)
-- Uso previsto:
--		local env = require("config.env")
--		if env.is_wsl then ... end

local M = {}

local uname = vim.loop.os_uname()
local sysname = uname.sysname or ""
local release = uname.release or ""

M.sysname = sysname
M.release = release

M.is_linux = sysname == "Linux"
M.is_macos = sysname == "Darwin"
M.is_windows = sysname:match("Windows") ~= nil

-- WSL: suele aparecer "microsoft" en release y/o WSL_INTEROP definido
M.is_wsl = (release:lower():match("microsoft") ~= nil) or (vim.env.WSL_INTEROP ~= nil)

-- Lee /etc/os-release si existe
local function read_os_release()
	local ok, f = pcall(io.open, "/etc/os-release", "r")
	if not ok or not f then
		return {}
	end

	local data = {}
	for line in f:lines() do
		local key, val = line:match("^(%w+)%=(.+)$")
		if key and val then
			-- quita comillas
			val = val:gsub('^"', ""):gsub('"$', "")
			data[key] = val
		end
	end
	f:close()
	return data
end

local osr = {}
if M.is_linux then
	osr = read_os_release()
end

local id = (osr.ID or ""):lower()
local id_like = (osr.ID_LIKE or ""):lower()

M.distro_id = id
M.distro_like = id_like

-- Detecciones concretas
M.is_arch = id == "arch"
M.is_ubuntu = id == "ubuntu"
M.is_debian_like = (id == "debian") or (id_like:match("debian") ~= nil)
M.is_amazon_linux = (id == "amzn") or (id_like:match("amazon") ~= nil)

-- Heuristica para entorno AWS (EC2, contenedores gestionados, etc.)
M.is_aws = M.is_amazon_linux or (vim.env.AWS_EXECUTION_ENV ~= nil) or (id_like:match("aws") ~=nil)

-- Atajos de alto nivel
M.is_desktop_linux = M.is_linux and not M.is_wsl and not M.is_aws

return M
