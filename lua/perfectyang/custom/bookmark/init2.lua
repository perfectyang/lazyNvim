local LRU = require("perfectyang.custom.bookmark.lru")
local lru = LRU.new(3)
local M = {}

local self_next_mark = string.byte("A")

function M.is_uppercase_mark(mark)
  return mark:match("^[A-Z]$") ~= nil
end

function M.get_cursor_info()
  local file_path = vim.fn.expand("%:p")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1]
  local col_num = cursor[2] + 1 -- 转换为 1-based 索引
  print(file_path .. "------" .. line_num .. "--------" .. col_num)
  return {
    file_path,
    line_num,
    col_num,
  }
end

-- 使用这个函数
-- function M.findMarkPos(tbl, start_element)
--   local index = 0
--   local length = #tbl
--   for i, v in ipairs(tbl) do
--     if start_element == nil then
--       index = 0
--       break
--     elseif v == start_element then
--       print("找到起始元素的索引" .. v)
--       index = i
--       break
--     end
--   end
--   return index, length
-- end
--
-- function M.create_cyclic_iterator(tbl, start_element, direction)
--   local index, length = M.findMarkPos(tbl, start_element)
--
--   if direction == "next" then
--     index = index + 1
--   elseif direction == "prev" then
--     index = index - 1
--   end
--   if index > length then
--     index = 0
--   elseif index < 0 then
--     index = length
--   end
--
--   return tbl[index]
-- end

function M.get_mark()
  -- 获取所有标记
  local marks = vim.fn.execute("marks")
  local lines = vim.split(marks, "\n")
  -- print("lines" .. vim.inspect(lines))
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
  local isExist, marks = M.check_mark_at_cursor()
  if isExist then
    lru:setIndexFormMark(marks[1])
  end
  local mark
  if type == 1 then
    mark = lru:goNext()
  else
    mark = lru:goPrev()
  end
  if mark ~= nil then
    print("访问" .. mark)
    vim.cmd("normal! '" .. mark)
  else
    print("No next mark found")
  end
end

function M.set_mark()
  if self_next_mark > string.byte("C") then
    self_next_mark = string.byte("A")
  end
  local mark = string.char(self_next_mark)
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_buf_set_mark(buf, mark, pos[1], pos[2], {})
  lru:put(mark, mark)
  lru:logState()
  self_next_mark = self_next_mark + 1
end

function M.check_mark_at_cursor()
  -- 获取当前光标位置
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor_pos[1]
  -- 定义所有可能的标记
  local marks = M.get_mark()
  -- 检查每个标记
  local found_marks = {}
  for _, mark in ipairs(marks) do
    local mark_pos = vim.api.nvim_buf_get_mark(0, mark)
    if mark_pos[1] == cursor_line then
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

vim.keymap.set("n", "mm", function()
  local isExist, marks = M.check_mark_at_cursor()
  if isExist then
    print("当前光标标记已存在", marks[1])
  else
    M.set_mark()
  end
end, { noremap = true })
vim.keymap.set("n", "mn", function()
  M.next_mark(1)
end, { noremap = true })

vim.keymap.set("n", "mb", function()
  M.next_mark(2)
end, { noremap = true })

function M.setup()
  local tabl = M.get_mark()
  for _, v in ipairs(tabl) do
    if v == "A" or v == "B" or v == "C" then
      lru:put(v, v)
    end
  end
end

vim.keymap.set("n", "ml", function()
  lru:logState()
end, { noremap = true })

vim.keymap.set("n", "mf", function()
  M.get_cursor_info()
end, { noremap = true })

vim.keymap.set("n", "mc", function()
  vim.cmd("delmarks!")
  vim.cmd("delmarks A-Z0-9")
  lru:initConfig()
end, { noremap = true })

-- M.setup()

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    M.setup()
  end,
})

local named_marks = {}

local function set_named_mark(name)
  named_marks[name] = {
    file = vim.fn.expand("%:p"),
    line = vim.fn.line("."),
    col = vim.fn.col("."),
  }
  print("Mark set: " .. name)
end

local function jump_to_named_mark(name)
  local mark = named_marks[name]
  if mark then
    vim.cmd("edit " .. mark.file)
    vim.api.nvim_win_set_cursor(0, { mark.line, mark.col - 1 })
  else
    print("Mark not found: " .. name)
  end
end

-- 设置命令
vim.api.nvim_create_user_command("MarkSet", function(opts)
  set_named_mark(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("MarkJump", function(opts)
  jump_to_named_mark(opts.args)
end, { nargs = 1 })

return {}
