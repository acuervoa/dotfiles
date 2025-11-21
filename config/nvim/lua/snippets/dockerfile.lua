-- lua/snippets/dockerfile.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
FROM <base_image>

WORKDIR /app

COPY . . 

CMD [ "<cmd>", "<arg1>" ]
			]],
			{
				base_image = i(1, "alpine:3.24"),
				cmd = i(2, "sh"),
				arg1 = i(3, "-c"),
			}
		)
	),
}
