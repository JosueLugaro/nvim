return {
	{
	    "ThePrimeagen/harpoon",
	    branch = "harpoon2",
	    dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()
        end,
        keys = {
            {
                "<leader>a",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "Harpoon add file",
            },
            {
                "<leader>h",
                function()
                    local harpoon = require("harpoon")

                    --  Original menu:
                    harpoon.ui:toggle_quick_menu(harpoon:list())

--                    -- basic telescope configuration
--                    local conf = require("telescope.config").values
--                    local function toggle_telescope(harpoon_files)
--                        local file_paths = {}
--                        for _, item in ipairs(harpoon_files.items) do
--                            table.insert(file_paths, item.value)
--                        end
--
--                        require("telescope.pickers").new({}, {
--                            prompt_title = "Harpoon",
--                            finder = require("telescope.finders").new_table({
--                                results = file_paths,
--                            }),
--                            previewer = conf.file_previewer({}),
--                            sorter = conf.generic_sorter({}),
--                        }):find()
--                    end
--
--                    -- Use telescope as Harpoon UI
--                    toggle_telescope(harpoon:list())
                end,
                desc = "Harpoon quick menu",
            },
            {
                "<leader>1",
                function()
                    require("harpoon"):list():select(1)
                end,
                desc = "Harpoon to file 1",
            },
            {
                "<leader>2",
                function()
                    require("harpoon"):list():select(2)
                end,
                desc = "Harpoon to file 2",
            },
            {
                "<leader>3",
                function()
                    require("harpoon"):list():select(3)
                end,
                desc = "Harpoon to file 3",
            },
            {
                "<leader>4",
                function()
                    require("harpoon"):list():select(4)
                end,
                desc = "Harpoon to file 4",
            },
        }
	}
}
