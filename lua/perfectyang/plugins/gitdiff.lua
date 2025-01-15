-- co — 采用当前的更改
-- ct — 采用传入的更改
-- cb — 保留双方更改
-- c0 — choose none
-- ]x — move to previous conflict
-- [x — move to next conflict
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = function()
    require("git-conflict").setup({
      -- {
      --   ours = "o",
      --   theirs = "t",
      --   both = "b",
      --   none = "0",
      --   next = "n",
      --   prev = "p",
      -- }
      -- default_mappings = false,
    })
    vim.keymap.set("n", "<leader>1", "<Plug>(git-conflict-ours)")
    vim.keymap.set("n", "<leader>2", "<Plug>(git-conflict-theirs)")
    vim.keymap.set("n", "<leader>3", "<Plug>(git-conflict-both)")
  end,
}
