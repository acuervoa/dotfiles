-- lua/snippets/go.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
package main

import "fmt"

func main() {
	<body>
}
			]],
			{
				body = i(0, 'fmt.Println("Hello, world!")'),
			}
		)
	),
}
