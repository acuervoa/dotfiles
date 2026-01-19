local utils = require("new-file-template.utils")

local function py_template(path, filename)
	return [[#!/usr/bin/env python3

from __future__ import annotations


def main() -> None:
    |cursor|


if __name__ == "__main__":
    main()
]]
end

return function(opts)
	local templates = {
		{ pattern = ".*", content = py_template },
	}

	return utils.find_entry(templates, opts)
end
