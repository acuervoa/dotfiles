local codex = require("codex")
local t = codex.__test

describe("codex helper functions", function()
	it("clean_output extracts codex block", function()
		local input = {
			"noise",
			"codex",
			"line 1",
			"line 2",
			"tokens used 123",
			"ignored",
		}

		assert.are.same({ "line 1", "line 2" }, t.clean_output(input))
	end)

	it("clean_output falls back when markers missing", function()
		local input = { "a", "b" }
		assert.are.same(input, t.clean_output(input))
	end)

	it("append_non_empty appends only non-empty chunks", function()
		local target = { "x" }
		t.append_non_empty(target, { "", "a", nil, "b" })
		assert.are.same({ "x", "a", "b" }, target)
	end)

	it("normalize_selection_range swaps reversed positions", function()
		local a = { 0, 10, 20 }
		local b = { 0, 5, 1 }
		local start_pos, end_pos = t.normalize_selection_range(a, b)

		assert.are.same(b, start_pos)
		assert.are.same(a, end_pos)
	end)

	it("make_prompt concatenates safely", function()
		assert.are.same("abcdef", t.make_prompt("abc", "def"))
		assert.are.same("abc", t.make_prompt("abc", nil))
		assert.are.same("def", t.make_prompt(nil, "def"))
	end)

	it("default commands keep backward compatibility alias", function()
		assert.are.same("explain_repo", t.default_commands.CodexExplainReoi)
		assert.are.same("explain_repo", t.default_commands.CodexExplainRepo)
	end)

	it("has_non_whitespace validates meaningful content", function()
		assert.is_true(t.has_non_whitespace("hola"))
		assert.is_false(t.has_non_whitespace("   \n\t  "))
		assert.is_false(t.has_non_whitespace(nil))
	end)
end)
