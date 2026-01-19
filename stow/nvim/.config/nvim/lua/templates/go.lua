local utils = require("new-file-template.utils")

local function main_template(path, filename)
	return [[package main

import "fmt"

func main() {
    fmt.Println("|cursor|")
}
]]
end

local function lib_template(path, filename)
	-- nombre de paquete = último segmento de la ruta
	local pkg = path:match("([^/]+)$") or "pkg"

	return "package " .. pkg .. [[

]] .. [[
]]
end

return function(opts)
	local template = {
		-- Ficheros bajo cmd/ → binario con main()
		{ pattern = "^cmd/.*", content = main_template },
		-- Ficheros bajo pkg/ o internal/ → paquete librería
		{ pattern = "^pkg/.*", content = lib_template },
		{ pattern = "^internal/.*", content = lib_template },
		-- Fallback: si no cae en nada, también librería
		{ pattern = ".*", content = lib_template },
	}

	return utils.find_entry(template, opts)
end
