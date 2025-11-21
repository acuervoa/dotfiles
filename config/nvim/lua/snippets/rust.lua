-- lua/snippets/rust.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
fn main() {
	<body>
}

			]],
			{
				body = i(0, 'println!("Hello, world!");'),
			}
		)
	),
}
