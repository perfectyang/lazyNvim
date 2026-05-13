-- 创建高亮组（在 Neovim/Vim 中）
vim.cmd([[
  highlight CharHighlight guibg=#ff0000 ctermbg=#ff0000
]])

-- 配置选项（可自定义）
local config = {
  target_char = "console", -- 默认检测的字符
  enabled = true, -- 插件开关
}

-- 高亮检测函数
local function highlight_char()
  if not config.enabled then
    return
  end

  -- 清除之前的高亮
  vim.fn.clearmatches()

  -- 获取当前缓冲区内容
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- 遍历所有行
  for i, line in ipairs(lines) do
    if line:find(config.target_char, 1, true) then -- 精确匹配字符
      -- 添加高亮匹配
      vim.fn.matchaddpos("CharHighlight", { { i } })
    end
  end
end

-- 更新配置函数
local function setup(user_config)
  config = vim.tbl_extend("force", config, user_config or {})

  -- 自动命令组
  local group = vim.api.nvim_create_augroup("CharHighlighter", { clear = true })

  -- 设置自动触发事件
  vim.api.nvim_create_autocmd({ "TextChanged", "BufEnter", "TextChangedI" }, {
    group = group,
    pattern = "*",
    callback = highlight_char,
  })
end

setup()

-- 导出函数
return {
  -- setup = setup,
  -- toggle = function()
  --   config.enabled = not config.enabled
  --   highlight_char()
  --   print("插件状态:", config.enabled and "启用" or "禁用")
  -- end,
}
