return {
  "ThePrimeagen/harpoon",
  -- branch = "harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon").setup({
      global_settings = {
        -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
        save_on_toggle = false,

        -- saves the harpoon file upon every change. disabling is unrecommended.
        save_on_change = true,

        -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
        enter_on_sendcmd = false,

        -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
        tmux_autoclose_windows = true,

        -- filetypes that you want to prevent from adding to the harpoon list menu.
        excluded_filetypes = { "harpoon" },

        -- set marks specific to each git branch inside git repository
        -- Each branch will have it's own set of marked files
        mark_branch = true,

        -- enable tabline with harpoon marks
        tabline = false,
        tabline_prefix = "   ",
        tabline_suffix = "   ",
      },
    })

    vim.keymap.set("n", "<leader>mm", require("harpoon.mark").add_file)
    vim.keymap.set("n", "<leader>mn", require("harpoon.ui").nav_next)
    vim.keymap.set("n", "<leader>mb", require("harpoon.ui").nav_prev)
    vim.keymap.set("n", "<leader>fm", ":Telescope harpoon marks<CR>") -- list current changes per file with diff preview ["gs" for git status]
    vim.keymap.set("n", "<leader>me", ":lua require('harpoon.ui').toggle_quick_menu()<CR>") -- list current changes per file with diff preview ["gs" for git status]
  end,
}
