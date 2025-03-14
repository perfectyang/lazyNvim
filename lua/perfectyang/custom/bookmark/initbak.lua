local M = {}

local self_next_mark = string.byte("A")
local self_prev_mark = string.byte("A")

function M.is_uppercase_mark(mark)
  return mark:match("^[A-Z]$") ~= nil
end

function M.findMarkPos(tbl, start_element)
  local index = 0
  local length = #tbl
  for i, v in ipairs(tbl) do
    if start_element == nil then
      index = 0
      break
    elseif v == start_element then
      print("找到起始元素的索引" .. v)
      index = i
      break
    end
  end
  return index, length
end

function M.create_cyclic_iterator(tbl, start_element, direction)
  local index, length = M.findMarkPos(tbl, start_element)

  if direction == "next" then
    index = index + 1
  elseif direction == "prev" then
    index = index - 1
  end
  if index > length then
    index = 0
  elseif index < 0 then
    index = length
  end

  return tbl[index]
end

function M.get_mark()
  -- 获取所有标记
  local marks = vim.fn.execute("marks")
  local lines = vim.split(marks, "\n")
  -- 收集所有大写标记
  local markTable = {}
  for i = 2, #lines do
    local mark = vim.split(lines[i], "%s+")
    if #mark >= 3 then
      local isUpper = M.is_uppercase_mark(mark[2])
      if isUpper then
        table.insert(markTable, mark[2])
      end
    end
  end
  return markTable
end

function M.next_mark(type)
  local markTable = M.get_mark()
  local _mk = M.create_cyclic_iterator(markTable, string.char(self_next_mark), type or "next")
  self_next_mark = string.byte(_mk)
  -- 如果找到下一个标记，跳转到该标记
  if self_next_mark ~= nil then
    vim.cmd("normal! '" .. string.char(self_next_mark))
  else
    print("No next mark found")
  end
end

function M.set_mark()
  if self_next_mark > string.byte("Z") then
    self_next_mark = string.byte("A")
  end
  local mark = string.char(self_next_mark)
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)

  print('标记设置为"' .. mark .. '"')
  vim.api.nvim_buf_set_mark(buf, mark, pos[1], pos[2], {})
  local _m = "WarningSign" .. mark
  vim.fn.sign_define(_m, {
    text = mark, -- 使用 Unicode 字符作为图标
    texthl = "WarningMsg",
    numhl = "WarningMsg",
  })
  vim.fn.sign_place(0, "BreakpointGroup", _m, buf, { lnum = pos[1] })
  self_prev_mark = self_next_mark
  self_next_mark = self_next_mark + 1
end

function M.check_mark_at_cursor()
  -- 获取当前光标位置
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor_pos[1]
  local cursor_col = cursor_pos[2]

  -- 定义所有可能的标记
  local marks = M.get_mark()
  -- 检查每个标记
  local found_marks = {}
  for _, mark in ipairs(marks) do
    local mark_pos = vim.api.nvim_buf_get_mark(0, mark)
    if mark_pos[1] == cursor_line and mark_pos[2] == cursor_col then
      table.insert(found_marks, mark)
    end
  end

  -- 返回结果
  if #found_marks > 0 then
    return true, found_marks
  else
    return false, {}
  end
end

vim.keymap.set("n", "<F12>", function()
  local isExist, marks = M.check_mark_at_cursor()
  if isExist then
    print("标记已存在")
  else
    M.set_mark()
  end
end, { noremap = true })
-- 设置快捷键映射
vim.keymap.set("n", "<F10>", function()
  M.next_mark("next")
end, { noremap = true })

vim.keymap.set("n", "<F9>", function()
  M.next_mark("prev")
end, { noremap = true })

return {}
