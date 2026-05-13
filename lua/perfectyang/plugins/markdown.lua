return {
  "MeanderingProgrammer/render-markdown.nvim",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
  opts = {
    heading = {
      icons = {},
    },
    html = {
      comment = {
        conceal = false,
      },
    },
    render_modes = true,
  },
}
