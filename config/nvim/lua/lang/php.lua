-- lua/lang/php.lua
-- Configuración especifica para PHP (LSP, formateo, lint, tests, etc.)
-- Objetivo: centralizar todo lo propio de PHP en un único módulo.

local env = require("config.env")

local M = {}

-- LSP (intelephense)
M.lsp = {
  server = "intelephense",
  settings = {
    files = { maxSize = 5000000 },
    -- Desacrivamos el formateo del LSP porque usamos herramientas externas (conform)
    format = { enable = false },
  },
}

-- Formateo (conform.nvim)
M.format = {
  -- Orden de preferencia: primero Pint (si existe en el proyecto), luego php-cs-fixer
  formatters = { "pint", "php_cs_fixer" },
}

-- Lint (nvim-lint)
M.lint = {
  linters = { "phpstan" },
}

-- Tests (neotest-phpunit)
--
local function phpunit_cmd()
  if env.is_aws then
    return { "php", "vendor/bin/phpunit" }
  end

  if env.is_wsl then
    return { "docker", "compose", "exec", "php" ,"php", "vendor/bin/phpunit" }
  end

  if env.is_desktop_linux then
    return { "docker", "compose", "exec", "php" ,"php", "vendor/bin/phpunit" }
  end

  -- Fallback
  return { "php", "vendor/bin/phpunit" }
end

M.tests = {
  neotest = {
    phpunit = {
      phpunit_cmd = phpunit_cmd,
    },
  },
}

return M
