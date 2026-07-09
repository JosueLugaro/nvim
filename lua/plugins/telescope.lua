return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'BurntSushi/ripgrep',
            'nvim-treesitter/nvim-treesitter',
            -- Sorter to improve sorting performance
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        },
        config = function()
            local telescope = require('telescope')
            local builtin = require('telescope.builtin')
            
            telescope.setup({
                pickers = {
                    find_files = {
                        hidden = true,
                        cwd = vim.fn.getcwd()
                    },
                    live_grep = {
                        cwd = vim.fn.getcwd()
                    }
                },
                defaults = {
                    vimgrep_arguments = {
                        'rg',
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                        '--hidden'
                    }
                }
            })
            telescope.load_extension('fzf')
        end,
        keys = {
            {'<leader>ff', function() require('telescope.builtin').find_files({ cwd = vim.fn.getcwd() }) end, desc = 'Telescope find files'},
            {'<leader>fg', function() require('telescope.builtin').live_grep({ cwd = vim.fn.getcwd() }) end, desc = 'Telescope live grep'},
            {'<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Telescope buffers'},
            {'<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Telescope help tags'}
        }
    }
}
