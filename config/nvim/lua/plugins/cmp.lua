return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp","hrsh7th/cmp-buffer","hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip","saadparwaiz1/cmp_luasnip","rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
    local cmp, luasnip, lspkind = require("cmp"), require("luasnip"), require("lspkind")
    cmp.setup({
      snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
      window  = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", maxwidth = 50, ellipsis_char = "...",
          before = function(entry, item)
            item.menu = ({ nvim_lsp="[LSP]", luasnip="[Snippet]", buffer="[Buffer]", path="[Path]" })[entry.source.name]
            return item
          end
        })
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
          else fallback() end
        end, { "i","s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then luasnip.jump(-1)
          else fallback() end
        end, { "i","s" }),
      }),
      sources = cmp.config.sources(
        { { name="nvim_lsp", priority=1000 }, { name="luasnip", priority=750 }, { name="path", priority=500 } },
        { { name="buffer", priority=250, keyword_length=3 } }
      ),
      experimental = { ghost_text = { hl_group = "Comment" } },
    })
  end
}
