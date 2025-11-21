-- lua/snippets/bash.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
#!/usr/bin/env bash
set -euo pipefail

<body>

			]],
			{
				body = i(0, 'echo "Hello, world!"'),
			}
		)
	),
}
