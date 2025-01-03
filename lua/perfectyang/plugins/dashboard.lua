return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({})
  end,
  requires = { "nvim-tree/nvim-web-devicons" },
}
