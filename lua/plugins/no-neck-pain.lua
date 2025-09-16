return {
    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        config = function()
            require("no-neck-pain").setup({
                width = 115,
                autocmds = {
                    enableOnVimEnter = true
                },
                buffers = {
                    scratchPad = {
                        enabled = true,
                        location = "~/Documents/",
                    },
                    bo = {
                        filetype = "md",
                    },
                },
            })
        end
    }
}
