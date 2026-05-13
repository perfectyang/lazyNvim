local git_buffers = require("perfectyang.custom.tempnote.note")
-- local sda = require("perfectyang.custom.tempnote.sda")
-- local terminal = require("perfectyang.custom.tempnote.terminal")

-- 创建一个命令来切换 Git 分支笔记的浮动窗口
vim.api.nvim_create_user_command("GitNotes", function()
  git_buffers.toggle_project_branch_notes()
end, {})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
    if current_branch ~= "" and current_branch ~= vim.b.last_git_branch then
      vim.b.last_git_branch = current_branch
      vim.cmd("doautocmd User GitBranchChanged")
    end
  end,
})

-- 设置一个快捷键
vim.api.nvim_set_keymap("n", "<leader>tn", ":GitNotes<CR>", { noremap = true, silent = true })
--
-- vim.keymap.set("n", "<F3>", function()
--   terminal.open()
-- end, { noremap = true })

-- vim.api.nvim_create_user_command("Tb", function()
--   require("perfectyang.custom.tempnote.db").add_user("perfectyang", "v")
-- end, { desc = "Show Recent Yanks" })
--
-- vim.api.nvim_create_user_command("Vb", function()
--   local data = require("perfectyang.custom.tempnote.db").get_data()
--   print(vim.inspect(data:get()))
-- end, {})
--
-- terminal.setup()

-- vim.g.insert_positions = {}
-- vim.g.insert_position_index = -1
--
-- local function record_insert_position()
--   local pos = vim.fn.getpos(".")
--   table.insert(vim.g.insert_positions, pos)
--   vim.g.insert_position_index = #vim.g.insert_positions
-- end
--
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   callback = function()
--     record_insert_position()
--   end,
-- })
-- local a = "asdf"
-- local function cycle_insert_positions(direction)
--   print(#vim.g.insert_positions)
--   if #vim.g.insert_positions == 0 then
--     -- print("No insert positions recorded")
--     return
--   end
--
--   if direction == "next" then
--     vim.g.insert_position_index = (vim.g.insert_position_index % #vim.g.insert_positions) + 1
--   elseif direction == "prev" then
--     vim.g.insert_position_index = ((vim.g.insert_position_index - 2) % #vim.g.insert_positions) + 1
--   end
--
--   vim.fn.setpos(".", vim.g.insert_positions[vim.g.insert_position_index])
--   print(string.format("Moved to insert position %d of %d", vim.g.insert_position_index, #vim.g.insert_positions))
-- end
--
-- vim.keymap.set("n", "<leader>mn", function()
--   cycle_insert_positions("next")
-- end, { desc = "Deletes a mark" })
--
-- vim.keymap.set("n", "<leader>mp", function()
--   cycle_insert_positions("prev")
-- end, { desc = "Deletes a mark" })

return {}
