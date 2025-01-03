return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      -- 使用 nvim 内置lsp
      diagnostics = "nvim-lsp",
      -- 左侧让出 nvim-tree 的位置
      hover = {
        enabled = true,
        delay = 100,
        reveal = { "close" },
      },

      buffer_close_icon = "",
      close_command = "bdelete %d",
      close_icon = "",
      indicator = {
        style = "icon",
        icon = " ",
      },
      left_trunc_marker = "",
      modified_icon = "●",
      offsets = { { filetype = "NvimTree", text = "EXPLORER", text_align = "center" } },
      right_mouse_command = "Bdelete! %d",
      right_trunc_marker = "",
      show_close_icon = false,
      show_tab_indicators = true,
    },
  },
}
