return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      config = {
        header = {
          "",
        },
        project = {
          label = "最近打开过的文件: ",
        },
        mru = {
          label = "经常打开过的文件: ",
        },
        shortcut = {},
        packages = {
          enabled = false,
        },
        footer = {},
      },
    })
  end,
  requires = { "nvim-tree/nvim-web-devicons" },
}
