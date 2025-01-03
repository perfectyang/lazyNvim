return {
  "Mofiqul/vscode.nvim",
  priority = 1000,
  config = function()
    local c = require("vscode.colors").get_colors()
    require("vscode").setup({
      color_overrides = {

        vscNone = "NONE",
        -- vscFront = "#D4D4D4",
        vscFront = "#D4D4D4", -- 文件字体颜色
        vscBack = "#070707", -- 背景色
        vscLeftDark = "#070707", -- 左侧背景色
        vscCursorDarkDark = "#070707", -- 在当前行背景色
        vscSelection = "#1c5894", --- 选中文字颜色
        vscSearch = "#b24a07", -- 搜索文案
        vscTabCurrent = "#070707",
        vscBlue = "#5383c3",
        vscLineNumber = "#5A5A5A",
      },
    })
    vim.cmd("colorscheme vscode")
  end,
}
