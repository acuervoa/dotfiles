local utils = require("new-file-template.utils")

local function rust_template(path, filename)
	return [[fn main() {
    |cursor|
}
]]
end

return function(opts)
	local templates = {
		{ pattern = ".*", content = rust_template },
	}

	return utils.find_entry(templates, opts)
end
