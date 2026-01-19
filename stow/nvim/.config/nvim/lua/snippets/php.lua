local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  -- Método de test PHPUnit
  s("phpt", {
    t("public function test_"),
    i(1, "it_does_something"),
    t("(): void"),
    t({ "", "{" }),
    t({ "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Método público genérico
  s("phpfn", {
    t("public function "),
    i(1, "name"),
    t("("),
    i(2),
    t(")"),
    t({ "", "{" }),
    t({ "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- Docblock simple
  s("phpdoc", {
    t({ "/**", " * " }),
    i(1, "Descripción"),
    t({ "", " *", " * @return " }),
    i(2, "void"),
    t({ "", " */" }),
  }),

  -- Debug rápido
  s("dd", {
    t("dd("),
    i(1, "$var"),
    t(");"),
  }),
}

