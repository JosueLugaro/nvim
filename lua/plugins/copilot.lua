-- Copilot (zbirenbaum/copilot.lua) plugin spec for lazy.nvim
-- Place this file at lua/plugins/copilot.lua (lazy will pick it up under your plugins/ import)
return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-l>", -- optional dedicated accept key
            accept_word = false,
            accept_line = false,
            next = "<C-]>",
            prev = "<C-[>",
            dismiss = "<C-/>",
          },
        },
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            open = "<M-CR>",
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            close = "<C-e>",
          },
        },
        filetypes = {
          ["*"] = true,
        },

        -- Permissive should_attach: attach to normal listed buffers with a filetype.
        -- Adjust to be more strict if you want to exclude specific filetypes.
        should_attach = function(bufnr)
          local buftype = vim.bo[bufnr].buftype
          local ft = vim.bo[bufnr].filetype
          if buftype ~= "" and buftype ~= " " then return false end   -- skip terminal, prompt, etc.
          if not ft or ft == "" then return false end                 -- skip buffers with no filetype
          return true
        end,
      })

      -- Accept inline suggestion with <C-l> using copilot.lua Lua API
      vim.keymap.set("i", "<C-l>", function()
        local ok, sugg = pcall(require, "copilot.suggestion")
        if ok and sugg and sugg.is_visible() then
          sugg.accept()
        end
      end, { noremap = true, silent = true })

      -- Aggressive dismiss helper: schedule a dismiss, then try clear/close defensively.
      local function aggressive_dismiss()
        vim.schedule(function()
          local ok, sugg = pcall(require, "copilot.suggestion")
          if not ok or not sugg then return end

          -- Try standard dismiss if visible
          pcall(function()
            if sugg.is_visible() then sugg.dismiss() end
          end)

          -- Defensive calls for different versions/internal state
          pcall(function() if sugg.clear then sugg.clear() end end)
          pcall(function() if sugg.close then sugg.close() end end)
        end)
      end

      -- Ensure Ctrl-C also dismisses Copilot suggestions reliably, then do regular <C-c>
      vim.keymap.set("i", "<C-c>", function()
        -- try to dismiss copilot suggestion first (non-blocking)
        pcall(function() aggressive_dismiss() end)
        -- then perform the normal Ctrl-C behavior to leave insert mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", true)
      end, { noremap = true, silent = true })

      -- Dismiss on leaving insert mode (scheduled to avoid races)
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = aggressive_dismiss,
      })

      -- Also dismiss on common typing/move events while inserting and on buffer leave/write
      vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChangedI", "BufLeave", "BufWritePost" }, {
        callback = aggressive_dismiss,
      })

      -- Debug helper: tells you why copilot did/didn't attach to current buffer
      vim.api.nvim_create_user_command("CopilotWhy", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
        local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
        local ok, cfg = pcall(require, "copilot.config")
        local should = false
        if ok and cfg and cfg.should_attach then
          should = cfg.should_attach(bufnr)
        end
        vim.notify(string.format("filetype=%s buftype=%s should_attach=%s", ft, buftype, tostring(should)))
      end, {})

    end,
  },

  -- copilot-cmp so copilot suggestions appear as a cmp source
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
    config = function()
      require("copilot_cmp").setup({
        method = "getCompletionsCycling",
      })
    end,
  },
}
