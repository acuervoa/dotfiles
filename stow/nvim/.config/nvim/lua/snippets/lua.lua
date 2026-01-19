local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  -- Módulo de plugin básico
  s("mod", {
    t("local M = {}"),
    t({ "", "", "function M.setup(" }),
    i(1, "opts"),
    t({ ")", "  " }),
    i(0, "-- TODO: configuración" ),
    t({ "", "end", "", "", "return M" }),
  }),

  -- Función local
  s("lfn", {
    t("local function "),
    i(1, "name"),
    t("("),
    i(2),
    t({ ")", "  " }),
    i(0),
    t({ "", "end" }),
  }),

  -- Vim command helper
  s("cmd", {
    t('vim.api.nvim_create_user_command("'),
    i(1, "Name"),
    t('", function('),
    i(2, "opts"),
    t({ ")", "  " }),
    i(0),
    t({ "", 'end, {}' }),
  }),
}

