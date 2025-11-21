-- lua/snippets/javascript.lua (Node)
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
#!/usr/bin/env node 
/* eslint-disable no-console */ 

async function main() {
	<body>
}

main().catch(err) => {
	console.error(err);
	process.exit(1);
});

			]],
			{
				body = i(0, 'console.log("Hello world!");'),
			}
		)
	),
}
