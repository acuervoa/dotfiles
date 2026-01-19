local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  s("tmod", {
    t({ "#[cfg(test)]", "mod tests {", "    use super::*;", "", "    #[test]", "    fn " }),
    i(1, "it_works"),
    t({ "() {", "        " }),
    i(0),
    t({ "", "    }", "}" }),
  }),
}

