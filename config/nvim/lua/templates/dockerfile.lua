local utils = require("new-file-template.utils")

local function docker_template(path, filename)
	return [[FROM alpine:3.20

WORKDIR /app

COPY . .

CMD ["sh", "-c", "|cursor|"]
]]
end

return function(opts)
	local templates = {
		{ pattern = ".*", content = docker_template },
	}

	return utils.find_entry(templates, opts)
end
