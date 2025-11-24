local utils = require("new-file-template.utils")

local function build_module_name(filename)
	local base = filename:gsub("%.tsx?$", "")
	return utils.snake_to_camel(base)
end

local function src_template(path, filename)
	local name = build_module_name(filename)

	return [[export function ]] .. name .. [[() {
    |cursor|
}
]]
end

local function test_template(path, filename)
	-- asumo Vitest; cambia a Jest si quieres
	local base = filename:gsub("%.test%.tsx?$", ""):gsub("%.spec%.tsx?$", "")
	local module_name = utils.snake_to_camel(base)

	return [[import { describe, it, expect } from "vitest";
import { ]] .. module_name .. [[ } from "../]] .. base .. [[";

describe("]] .. module_name .. [[", () => {
    it("works", () => {
        const result = ]] .. module_name .. [[();
        expect(result).toBeDefined();
    });
});
]]
end

return function(opts)
	local templates = {
		-- tests/xxx.test.ts, tests/xxx.spec.ts
		{ pattern = "^tests/.*%.test%.tsx?$", content = test_template },
		{ pattern = "^tests/.*%.spec%.tsx?$", content = test_template },

		-- __tests__/xxx.test.ts, __tests__/xxx.spec.ts
		{ pattern = "^__tests__/.*%.test%.tsx?$", content = test_template },
		{ pattern = "^__tests__/.*%.spec%.tsx?$", content = test_template },

		-- src/*.ts, src/*.tsx → módulo normal
		{ pattern = "^src/.*%.tsx?$", content = src_template },

		-- fallback: cualquier otro sitio → módulo normal
		{ pattern = ".*%.tsx?$", content = src_template },
	}

	return utils.find_entry(templates, opts)
end
