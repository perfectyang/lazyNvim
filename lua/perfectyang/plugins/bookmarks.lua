-- return {
--   -- "tomasky/bookmarks.nvim",
--   -- -- after = "telescope.nvim",
--   -- event = "VimEnter",
--   -- config = function()
--   --   require("bookmarks").setup({
--   --     on_attach = function(bufnr)
--   --       local bm = require("bookmarks")
--   --       local map = vim.keymap.set
--   --       map("n", "mm", bm.bookmark_toggle) -- add or remove bookmark at current line
--   --       map("n", "mi", bm.bookmark_ann) -- add or edit mark annotation at current line
--   --       map("n", "mc", bm.bookmark_clean) -- clean all marks in local buffer
--   --       map("n", "mn", bm.bookmark_next) -- jump to next mark in local buffer
--   --       map("n", "mp", bm.bookmark_prev) -- jump to previous mark in local buffer
--   --       map("n", "ml", bm.bookmark_list) -- show marked file list in quickfix window
--   --       map("n", "mx", bm.bookmark_clear_all) -- removes all bookmarks
--   --     end,
--   --   })
--   -- end,
-- }
return {
  -- "LintaoAmons/bookmarks.nvim",
  -- -- tag = "v2.3.0",
  -- dependencies = {
  --   { "kkharji/sqlite.lua" },
  --   { "nvim-telescope/telescope.nvim" },
  --   { "stevearc/dressing.nvim" }, -- optional: better UI
  -- },
  -- config = function()
  --   local opts = {} -- check the "./lua/bookmarks/default-config.lua" file for all the options
  --   require("bookmarks").setup(opts) -- you must call setup to init sqlite db
  -- end,
}
