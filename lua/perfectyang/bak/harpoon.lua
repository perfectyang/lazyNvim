return {
  "ThePrimeagen/harpoon",
  branch = "master",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})

    -- vim.keymap.set("n", "<leader>mm", require("harpoon.mark").add_file)
    -- vim.keymap.set("n", "<leader>mn", require("harpoon.ui").nav_next)
    -- vim.keymap.set("n", "<leader>mb", require("harpoon.ui").nav_prev)
    -- vim.keymap.set("n", "<leader>fm", ":Telescope harpoon marks<CR>") -- list current changes per file with diff preview ["gs" for git status]
    -- vim.keymap.set("n", "<leader>me", ":lua require('harpoon.ui').toggle_quick_menu()<CR>") -- list current changes per file with diff preview ["gs" for git status]
    --
    -- vim.keymap.set("n", "<leader>mm", function()
    --   harpoon:list():add()
    -- end)
    -- vim.keymap.set("n", "<leader>me", function()
    --   harpoon.ui:toggle_quick_menu(harpoon:list())
    -- end)
    --
    -- vim.keymap.set("n", "<leader>fm", function()
    --   toggle_telescope(harpoon:list())
    -- end, { desc = "Open harpoon window" })
  end,
}
