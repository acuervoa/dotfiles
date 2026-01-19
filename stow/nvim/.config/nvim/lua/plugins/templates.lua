-- lua/plugins/templates.lua
return {
	"otavioschwanck/new-file-template.nvim",
	opts = {
		-- Entra en modo INSERT después de insertar la plantilla
		disable_insert = false,
		-- Deja activado el autocmd de "nuevo archivo"
		disable_autocmd = false,
		-- Si algún dia molesta las plantillas por defecto:
		-- disable_filetype = { "ruby" }
	},
}

-- local utils = require("new-file-template.utils")
--
-- local function <lang>_template(path, filename)
--   -- construir string de plantilla y devolverlo
-- end
--
-- return function(opts)
--   local templates = {
--     { pattern = ".*", content = <lang>_template },
--   }
--
--   return utils.find_entry(templates, opts)
-- end
--
