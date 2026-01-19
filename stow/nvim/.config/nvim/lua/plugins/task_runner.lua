-- Task runner / Overseer + Harpoon
return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer: run task" },
      { "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Overseer: build task" },
    },
    opts = {
      templates = { "builtin" },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      local php = require("lang.php")
      local go_lang = require("lang.go")
      local rust = require("lang.rust")
      local python = require("lang.python")

      local templates = {}
      local function add(t)
        table.insert(templates, t)
      end
      local function has_file(f)
        return vim.loop.fs_stat(f) ~= nil
      end
      local function cmd_exists(cmd)
        return vim.fn.executable(cmd) == 1
      end

      local function has_compose()
        return has_file("docker-compose.yml") or has_file("docker-compose.yaml") or has_file("compose.yml") or has_file("compose.yaml")
      end

      -- JS/TS (elige gestor por lockfile)
      local function js_pm()
        if has_file("pnpm-lock.yaml") then
          return { "pnpm" }
        end
        if has_file("yarn.lock") then
          return { "yarn" }
        end
        if has_file("package-lock.json") then
          return { "npm" }
        end
        return nil
      end

      local function js_test_watch_cmd()
        local pm = js_pm()
        if not pm then
          return nil
        end
        if pm[1] == "yarn" then
          return { "yarn", "test", "--watch" }
        end
        return vim.list_extend(pm, { "test", "--", "--watch" })
      end

      add({
        name = "JS/TS: test",
        builder = function()
          local pm = js_pm()
          if not pm then
            return nil
          end
          return { cmd = vim.list_extend(pm, { "test" }), cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return js_pm() ~= nil end },
        tags = { "js", "ts", "test" },
        priority = 60,
      })

      add({
        name = "JS/TS: test (watch)",
        builder = function()
          local cmd = js_test_watch_cmd()
          if not cmd then
            return nil
          end
          return { cmd = cmd, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return js_test_watch_cmd() ~= nil end },
        tags = { "js", "ts", "test", "watch" },
        priority = 55,
      })

      add({
        name = "JS/TS: lint",
        builder = function()
          local pm = js_pm()
          if not pm then
            return nil
          end
          return { cmd = vim.list_extend(pm, { "run", "lint" }), cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return js_pm() ~= nil end },
        tags = { "js", "ts", "lint" },
        priority = 50,
      })

      add({
        name = "JS/TS: format",
        builder = function()
          local pm = js_pm()
          if not pm then
            return nil
          end
          return { cmd = vim.list_extend(pm, { "run", "format" }), cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return js_pm() ~= nil end },
        tags = { "js", "ts", "format" },
        priority = 40,
      })

      -- Python
      add({
        name = "Python: test (pytest)",
        builder = function()
          return { cmd = { "python", "-m", "pytest" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("pyproject.toml") or has_file("requirements.txt") end },
        tags = { "python", "test" },
        priority = 60,
      })

      add({
        name = "Python: test (watch)",
        builder = function()
          if not cmd_exists("ptw") then
            return nil
          end
          return { cmd = { "ptw" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return cmd_exists("ptw") end },
        tags = { "python", "test", "watch" },
        priority = 55,
      })

      add({
        name = "Python: lint (ruff)",
        builder = function()
          if not cmd_exists("ruff") then
            return nil
          end
          return { cmd = { "ruff", "check", "." }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return cmd_exists("ruff") end },
        tags = { "python", "lint" },
        priority = 50,
      })

      add({
        name = "Python: format (ruff)",
        builder = function()
          if not cmd_exists("ruff") then
            return nil
          end
          return { cmd = { "ruff", "format", "." }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return cmd_exists("ruff") end },
        tags = { "python", "format" },
        priority = 40,
      })

      -- Go
      add({
        name = "Go: test ./...",
        builder = function()
          return { cmd = { "go", "test", "./..." }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("go.mod") end },
        tags = { "go", "test" },
        priority = 60,
      })

      add({
        name = "Go: test (watch)",
        builder = function()
          if not cmd_exists("watchexec") then
            return nil
          end
          return {
            cmd = { "watchexec", "-e", "go", "--", "go", "test", "./..." },
            cwd = vim.fn.getcwd(),
            components = { "default" },
          }
        end,
        condition = { callback = function() return has_file("go.mod") and cmd_exists("watchexec") end },
        tags = { "go", "test", "watch" },
        priority = 55,
      })

      add({
        name = "Go: fmt (gofumpt)",
        builder = function()
          local fmt = cmd_exists("gofumpt") and "gofumpt" or "gofmt"
          return { cmd = { fmt, "-w", "." }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("go.mod") end },
        tags = { "go", "format" },
        priority = 50,
      })

      -- Rust
      add({
        name = "Rust: test",
        builder = function()
          return { cmd = { "cargo", "test" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("Cargo.toml") end },
        tags = { "rust", "test" },
        priority = 60,
      })

      add({
        name = "Rust: test (watch)",
        builder = function()
          if not cmd_exists("cargo-watch") then
            return nil
          end
          return { cmd = { "cargo", "watch", "-x", "test" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("Cargo.toml") and cmd_exists("cargo-watch") end },
        tags = { "rust", "test", "watch" },
        priority = 55,
      })

      add({
        name = "Rust: clippy",
        builder = function()
          return { cmd = { "cargo", "clippy" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("Cargo.toml") end },
        tags = { "rust", "lint" },
        priority = 50,
      })

      add({
        name = "Rust: fmt",
        builder = function()
          return { cmd = { "cargo", "fmt" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = function() return has_file("Cargo.toml") end },
        tags = { "rust", "format" },
        priority = 40,
      })

      -- Docker compose (básico)
      add({
        name = "Docker: compose up -d",
        builder = function()
          return { cmd = { "docker", "compose", "up", "-d" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = has_compose },
        tags = { "docker" },
        priority = 30,
      })

      add({
        name = "Docker: compose down",
        builder = function()
          return { cmd = { "docker", "compose", "down" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = has_compose },
        tags = { "docker" },
        priority = 25,
      })

      add({
        name = "Docker: compose logs -f",
        builder = function()
          return { cmd = { "docker", "compose", "logs", "-f" }, cwd = vim.fn.getcwd(), components = { "default" } }
        end,
        condition = { callback = has_compose },
        tags = { "docker", "logs" },
        priority = 20,
      })

      -- PHP (reusar plantillas definidas en lang/php.lua si existen)
      if php.tasks and php.tasks.overseer then
        for _, t in ipairs(php.tasks.overseer) do
          add(t)
        end
      end

      -- Registrar
      for _, t in ipairs(templates) do
        overseer.register_template(t)
      end
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      return {
        { "<leader>ha", function() harpoon:list():add() end, desc = "Harpoon add" },
        { "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon menu" },
        { "<leader>h1", function() harpoon:list():select(1) end, desc = "Harpoon 1" },
        { "<leader>h2", function() harpoon:list():select(2) end, desc = "Harpoon 2" },
        { "<leader>h3", function() harpoon:list():select(3) end, desc = "Harpoon 3" },
        { "<leader>h4", function() harpoon:list():select(4) end, desc = "Harpoon 4" },
        { "<leader>hn", function() harpoon:list():next() end, desc = "Harpoon next" },
        { "<leader>hp", function() harpoon:list():prev() end, desc = "Harpoon prev" },
        { "<leader>hQ", function() harpoon:list():clear() end, desc = "Harpoon clear" },
        { "<leader>hd", function() harpoon:list():remove() end, desc = "Harpoon delete current" },
      }
    end,
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })
    end,
  },
}
