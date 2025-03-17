local utils = require("perfectyang.custom.bookmark.utils")
local M = {}
-- 存储标记的表
local named_marks = {}
-- 当前标记的索引
local current_mark_index = 0

-- 设置命名标记
local function set_named_mark()
  local new_mark = {
    id = #named_marks + 1,
    file = vim.fn.expand("%:p"),
    line = vim.fn.line("."),
    col = vim.fn.col("."),
  }
  table.insert(named_marks, new_mark)
  current_mark_index = #named_marks
  M.save_marks()
  -- print(string.format("标记设置: %d at %s:%d:%d", new_mark.id, new_mark.file, new_mark.line, new_mark.col))
end

-- 跳转到指定标记
local function jump_to_mark(mark)
  vim.cmd("edit " .. mark.file)
  vim.api.nvim_win_set_cursor(0, { mark.line, mark.col - 1 })
  -- print(string.format("跳转到: %d at %s:%d:%d", mark.id, mark.file, mark.line, mark.col))
end

-- 跳转到下一个标记
local function jump_to_next_mark()
  if #named_marks == 0 then
    print("No marks set")
    return
  end
  current_mark_index = (current_mark_index % #named_marks) + 1
  jump_to_mark(named_marks[current_mark_index])
end

-- 跳转到上一个标记
local function jump_to_prev_mark()
  if #named_marks == 0 then
    print("No marks set")
    return
  end
  current_mark_index = ((current_mark_index - 2 + #named_marks) % #named_marks) + 1
  jump_to_mark(named_marks[current_mark_index])
end

-- 列出所有标记
local function list_marks()
  if #named_marks == 0 then
    print("No marks set")
    return
  end
  local strmap = {}
  for _, mark in ipairs(named_marks) do
    table.insert(strmap, string.format("%d: %s:%d:%d", mark.id, mark.file, mark.line, mark.col))
  end
  utils.toggle_window({ strmap = strmap })
end

-- 删除当前标记
local function delete_current_mark()
  if #named_marks == 0 then
    print("No marks to delete")
    return
  end
  local deleted_mark = table.remove(named_marks, current_mark_index)
  print(
    string.format(
      "Deleted mark: %d at %s:%d:%d",
      deleted_mark.id,
      deleted_mark.file,
      deleted_mark.line,
      deleted_mark.col
    )
  )
  if current_mark_index > #named_marks then
    current_mark_index = #named_marks
  end
end

function M.save_marks()
  local filePath = vim.fn.stdpath("data") .. "/" .. vim.fn.sha256(utils.get_project_branch_id()) .. ".json"
  local file = io.open(filePath, "w")
  if file then
    file:write(vim.fn.json_encode(named_marks))
    file:close()
  end
end

function M.load_marks()
  local filePath = vim.fn.stdpath("data") .. "/" .. vim.fn.sha256(utils.get_project_branch_id()) .. ".json"
  local file = io.open(filePath, "r")
  if file then
    local content = file:read("*all")
    file:close()
    named_marks = vim.fn.json_decode(content)
    current_mark_index = #named_marks > 0 and 1 or 0
  end
end

-- 在设置和删除标记后保存
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  callback = function()
    M.save_marks()
  end,
})

M.load_marks()

vim.api.nvim_create_autocmd("User", {
  pattern = "GitBranchChanged",
  callback = function()
    -- print("切换分支")
    M.load_marks()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
    if current_branch ~= "" and current_branch ~= vim.b.last_git_branch then
      vim.b.last_git_branch = current_branch
      vim.cmd("doautocmd User GitBranchChanged")
    end
  end,
})

-- 设置命令
vim.api.nvim_create_user_command("MarkSet", set_named_mark, {})
vim.api.nvim_create_user_command("MarkNext", jump_to_next_mark, {})
vim.api.nvim_create_user_command("MarkPrev", jump_to_prev_mark, {})
vim.api.nvim_create_user_command("MarkList", list_marks, {})
vim.api.nvim_create_user_command("MarkDelete", delete_current_mark, {})

-- 设置快捷键
vim.api.nvim_set_keymap("n", "mm", ":MarkSet<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "mn", ":MarkNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "mb", ":MarkPrev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ml", ":MarkList<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "mc", ":MarkDelete<CR>", { noremap = true, silent = true })

return {}
