return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = true,
  },
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
    },
    config = function()
      local cmp = require('cmp')
      local ok_ls, luasnip = pcall(require, "luasnip")
      if not ok_ls then
        luasnip = {
          expand_or_jumpable = function() return false end,
          expand_or_jump = function() end,
          jumpable = function() return false end,
          jump = function() end,
        }
        vim.schedule(function()
          vim.notify("LuaSnip not loaded; cmp Tab mappings will fallback.", vim.log.levels.WARN)
        end)
      end

      local function try_accept_copilot()
        local ok, sugg = pcall(require, "copilot.suggestion")
        if ok and sugg and sugg.is_visible() then
          sugg.accept()
          return true
        end
        return false
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            if ok_ls then
              luasnip.lsp_expand(args.body)
            end
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
          ['<C-n>'] = cmp.mapping.select_next_item({behavior = 'select'}),
          ['<CR>'] = cmp.mapping.confirm({select = false}),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if entry and entry.source and entry.source.name == "copilot" then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              if try_accept_copilot() then
                return
              end
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'copilot' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local cmp_nvim_lsp = require('cmp_nvim_lsp')

      -- Setup capabilities
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- LSP keybindings on attach
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP keybindings',
        callback = function(event)
          local opts = {buffer = event.buf}

          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
          vim.keymap.set({'n', 'x'}, '<F3>', function() vim.lsp.buf.format({async = true}) end, opts)
          vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
        end,
      })

      -- Setup mason-lspconfig
      require('mason-lspconfig').setup({
        ensure_installed = {
          'bashls',
          'dockerls',
          'docker_compose_language_service',
          'gopls',
          'lua_ls',
          'marksman',
          'pyright',
          'rust_analyzer',
          'terraformls',
          'ts_ls',
          'yamlls',
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({capabilities = capabilities})
          end,
          lua_ls = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = {version = 'LuaJIT'},
                  diagnostics = {globals = {'vim'}},
                  workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
                  },
                },
              },
            })
          end,
        },
      })
    end
  }
}

