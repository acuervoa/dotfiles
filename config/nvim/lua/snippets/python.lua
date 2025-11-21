-- lua/snippets/python.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
#!/usr/bin/env python3

from __future__ inport annotations

def main() -> None: 
	<body>

if __name__ == "__main__": 
	main()

			]],
			{
				body = i(0, "print('Hello, world!)"),
			}
		)
	),
}
