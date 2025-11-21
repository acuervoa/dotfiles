-- lua/snippets/php.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
	s(
		"file",
		fmta(
			[[ 
<?php
declare(strict_types=1);

namespace <namespace>

final class <class_name>
{
  public function __construct()
  {
    <body>
  }
}
      ]],
			{
				namespace = i(1, "App"),
				class_name = i(2, "ExampleClass"),
				body = i(0),
			}
		)
	),
}
