local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  s("pt", {
    t("def test_"),
    i(1, "it_does_something"),
    t("():"),
    t({ "", "    " }),
    i(0, "assert False"),
  }),
}

