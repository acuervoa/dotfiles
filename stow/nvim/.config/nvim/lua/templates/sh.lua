local utils = require("new-file-template.utils")

local function sh_template(path, filename)
	return [[#!/usr/bin/env bash
set -euo pipefail

|cursor|
]]
end

return function(opts)
	local templates = {
		{ pattern = ".*", content = sh_template },
	}

	return utils.find_entry(templates, opts)
end
