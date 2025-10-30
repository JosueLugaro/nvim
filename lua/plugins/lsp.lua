return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
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
    },
    config = function()
      -- Here you configure the nvim-cmp setup
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()
      -- Guarded require for luasnip should be placed near the top of the config() function:
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
      
      -- A safe helper to try accepting copilot inline suggestion:
      local function try_accept_copilot()
        local ok, sugg = pcall(require, "copilot.suggestion")
        if ok and sugg and sugg.is_visible() then
          sugg.accept()
          return true
        end
        return false
      end

      cmp.setup({
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          -- Navigate between completion items
          ['<C-p>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
          ['<C-n>'] = cmp.mapping.select_next_item({behavior = 'select'}),
          -- `Enter` key to confirm completion
          ['<CR>'] = cmp.mapping.confirm({select = false}),
          -- Ctrl+Space to trigger completion menu
          ['<C-Space>'] = cmp.mapping.complete(),
          -- Scroll up and down in the completion documentation
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          -- Not gonna lie, idk what this is
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
          
          -- Now the Tab mappings (insert these within your mapping = cmp.mapping.preset.insert({ ... }) table):
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if entry and entry.source and entry.source.name == "copilot" then
                -- confirm the selected copilot completion
                cmp.confirm({ select = true })
              else
                -- otherwise just move to next item
                cmp.select_next_item()
              end
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              -- If cmp isn't visible, try to accept the inline copilot suggestion
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
        })
      })
    end
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
      {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
      -- Here you configure the LSP setup
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      -- Add cmp_nvim_lsp capabilities settings to lspconfig
      local lspconfig_defaults = require('lspconfig').util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lspconfig_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      -- LSP actions
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = {buffer = event.buf}

          -- Show hover info
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)

          -- Go to definition
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)

          -- Go to declaration
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)

          -- Go to implementation
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)

          -- Go to type definition
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)

          -- Show references
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)

          -- Display signature help
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

          -- Rename symbol across the entire project
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)

          -- Formats the current buffer or selected range
          vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)

          -- Shows available code actions
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end,
      })

      lsp_zero.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      require('mason-lspconfig').setup({
        ensure_installed = {
            'bashls',
            'dockerls',
            'docker_compose_language_service',
            'gopls',
            'jdtls',
            'lua_ls',
            'marksman',
            'pyright',
            'terraformls',
            'yamlls',
        },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            -- (Optional) Configure lua language server for neovim
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        }
      })
    end
  }
}

