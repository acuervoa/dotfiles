local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  -- Función de test
  s("got", {
    t("func Test"),
    i(1, "Name"),
    t("(t *testing.T) {"),
    t({ "", "    " }),
    i(0),
    t({ "", "}" }),
  }),
}

