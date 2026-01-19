local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  -- Cabecera de script robusto
  s("shb", {
    t({ "#!/usr/bin/env bash",
        "",
        "set -Eeuo pipefail",
        "IFS=$'\\n\\t'",
        "",
        }),
    i(0),
  }),

  -- for-in típico
  s("forin", {
    t("for "),
    i(1, "item"),
    t(" in "),
    i(2, "\"$@\""),
    t({ "; do", "    " }),
    i(0),
    t({ "", "done" }),
  }),

  -- Comprobación de comando
  s("req", {
    t("command -v "),
    i(1, "cmd"),
    t({ " >/dev/null 2>&1 || {", "  echo '" }),
    i(2, "cmd is required"),
    t({ "' >&2; exit 1;", "}" }),
  }),
}

