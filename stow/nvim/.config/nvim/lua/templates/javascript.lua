local utils = require("new-file-template.utils")

local function js_template(path, filename)
	return [[#!/usr/bin/env node
/* eslint-disable no-console */

async function main() {
    |cursor|
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
]]
end

return function(opts)
	local templates = {
		{ pattern = ".*", content = js_template },
	}

	return utils.find_entry(templates, opts)
end
