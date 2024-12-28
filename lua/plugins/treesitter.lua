return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')

            configs.setup({
                ensure_installed = {
                    'lua',
                    'python',
                    'go',
                    'java',
                    'bash',
                    'dockerfile',
                    'yaml',
                    'terraform',
                    'markdown',
                    'markdown_inline',
                },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    }
}
