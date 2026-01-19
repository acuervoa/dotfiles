local utils = require("new-file-template.utils")

-- Construye el namespace a partir de la ruta del fichero
local function build_namespace(path)
	local root_src = vim.g.php_src_root_namespace or "App"
	local root_tests = vim.g.php_tests_root_namespace or "Tests"

	-- Normalizar
	path = path:gsub("^%./", "")

	local base_ns = root_src
	local relative = ""

	if path:match("^tests/") then
		base_ns = root_tests
		relative = path:match("^tests/(.*)$") or ""
	elseif path:match("^src/") then
		base_ns = root_src
		relative = path:match("^src/(.*)$") or ""
	else
		relative = path
	end

	local segments = {}
	for part in relative:gmatch("[^/]+") do
		if part ~= "" then
			table.insert(segments, utils.snake_to_class_camel(part))
		end
	end

	if #segments == 0 then
		return base_ns
	end

	return base_ns .. "\\" .. table.concat(segments, "\\")
end

local function class_template(path, filename)
	local base = vim.split(filename, "%.")[1]
	local class_name = utils.snake_to_class_camel(base)
	local namespace = build_namespace(path)

	return [[<?php 
  declare(strict_types=1);

  namespace ]] .. namespace .. [[;

  final class ]] .. class_name .. [[ 
  {
    public function __construct()
    {
      |cursor|
    }
  }
    ]]
end

local function test_template(path, filename)
	local base = filename:gsub("%.php$", ""):gsub("Test$", "")
	local class_under_test = utils.snake_to_class_camel(base)
	local namespace = build_namespace(path)

	return [[<?php
  declare(strict_types=1);

  namespace ]] .. namespace .. [[;

  use PHPUnit\Framework\TestCase;

  final class ]] .. class_under_test .. [[Test extends TestCase
  {
    public function test_it_works():void
    {
      $this->assertTrue(true);
    }
  }
    ]]
end

return function(opts)
	local template = {
		{ pattern = "^tests/.*", content = test_template },
		{ pattern = "^src/.*", content = class_template },
		{ pattern = ".*", content = class_template },
	}

	return utils.find_entry(template, opts)
end
