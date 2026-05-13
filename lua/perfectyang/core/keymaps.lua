vim.g.mapleader = ";"
local keymap = vim.keymap
local G = vim.g
local opts = { noremap = true, silent = true }
vim.g.skip_ts_context_commentstring_module = true

-- G.floaterm_keymap_kill = "<leader>5"
-- G.floaterm_keymap_new = "<leader>6"
-- G.floaterm_keymap_toggle = "<leader>7"
-- G.floaterm_keymap_next = "<leader>8"
-- G.floaterm_position = "center"
-- G.floaterm_title = "Perfectyang-$1/$2"
-- G.floaterm_width = 0.8
-- G.floaterm_height = 0.9
-- G.floaterm_giteditor = true
-- G.floaterm_opener = "edit"

-- ---------- 插入模式 ---------- ---
keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true })
keymap.set("i", "kj", "<ESC>", { noremap = true, silent = true })

-- ---------- 视觉模式 ---------- ---
-- 单行或多行移动
-- keymap.set("v", "J", ":m '>+2<CR>gv=gv")
-- keymap.set("v", "K", ":m '<-1<CR>gv=gv")

-- 窗口
-- ---------- 正常模式 ---------- ---
-- keymap.set("n", "<leader>q", ":q!<CR>") -- 垂直新增窗口
keymap.set("n", "<leader>;", ":w!<CR>")
keymap.set({ "n", "v" }, "J", "6j")
keymap.set({ "n", "v" }, "K", "6k")
keymap.set("n", "H", "^")
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
keymap.set("n", "L", "$")
keymap.set("n", "daf", "va{Vd")
keymap.set("n", "yaf", "va{Vy")
keymap.set("n", "yp", "Yp")
keymap.set("n", "Q", ":q!<CR>")
keymap.set("n", "D", "dd")
keymap.set("n", "Y", "yy")

-- 插入模式下用 Ctrl+l 向右移动一个字符（不退出插入模式）
keymap.set("i", "<C-l>", "<C-o>l") -- 左
keymap.set("i", "<C-h>", "<C-o>h") -- 右
keymap.set("i", "<C-j>", "<C-o>j") -- 下
keymap.set("i", "<C-k>", "<C-o>k") -- 上

keymap.set("n", "<C-a>", "ggVGy", {})
-- 标记可以不同文件夹之前跳转
local alp = {
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
}
local function getSetMark(list)
  for _, value in ipairs(list) do
    keymap.set("n", "m" .. value, "m" .. string.upper(value))
    keymap.set("n", "`" .. value, "`" .. string.upper(value))
  end
end
getSetMark(alp)
-- Move Lines

-- keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count2 + 1)<cr>==", { desc = "Move Up" })
-- keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count2<cr>==", { desc = "Move Down" })
-- keymap.set("i", "<A-j>", "<esc><cmd>m .+2<cr>==gi", { desc = "Move Down" })
-- keymap.set("i", "<A-k>", "<esc><cmd>m .-1<cr>==gi", { desc = "Move Up" })
keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count2<cr>gv=gv", { desc = "Move Down" })
keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count2 + 1)<cr>gv=gv", { desc = "Move Up" })

-- keymap.set("n", "<Space>", "zc")

-- 分割窗口
keymap.set("n", "<leader>sc", ":close<CR>", opts) -- 关闭窗口
-- keymap.set("n", "<leader>sv", ":vs<CR>", opts) -- 水平新增窗口
keymap.set("n", "<leader>sh", ":split<CR>", opts) -- 垂直新增窗口

-- aff

vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4001 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 301

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved

-- keymap.set("n", "gl", "<Plug>(coc-definition)", opts)

-- 取消高亮
keymap.set("n", "<CR>", ":nohl<CR>", opts)

-- 切换buffer
keymap.set("n", "<TAB>", ":bnext<CR>", opts)
keymap.set("n", "<S-TAB>", ":bprevious<CR>", opts)
keymap.set("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>", opts)
-- 清除所有buffer页
keymap.set("n", "<leader>c", ":bufdo bd<CR>", opts)

local ms = {
  "'",
  '"',
  "}",
  "{",
  ")",
  "(",
}

for _, value in ipairs(ms) do
  keymap.set("n", value, function()
    vim.cmd("normal! yiw")
    local word = vim.fn.getreg('"')
    if value == "}" or value == "{" then
      vim.cmd("normal! ciw{" .. word .. "}")
    elseif value == "(" or value == ")" then
      vim.cmd("normal! ciw(" .. word .. ")")
    else
      vim.cmd("normal! ciw" .. value .. word .. value)
    end
  end, {})
end
-- console.log("end",end)
-- keymap.set("n", "<leader>sv", function()
--   local width = math.floor(vim.o.columns * 1.4) -- 计算总宽度的 40%
--   vim.cmd(width .. "vsplit | term opencode")
-- end, {})
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
vim.fn.setreg("l", "viwyoconsole.log('" .. esc .. "pa', " .. esc .. "pa)" .. esc)

vim.keymap.set("n", "<leader>p", function()
  local cont = vim.fn.getreg("0")
  local content = "console.log('" .. cont .. "', " .. cont .. ")"
  vim.api.nvim_put({ content }, "c", false, true)
end, {})

keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", {
  noremap = true,
  silent = true,
}) -- see definition and make edits in window
keymap.set("n", "gh", vim.lsp.buf.code_action, {
  noremap = true,
  silent = true,
}) -- see available code action_

keymap.set("n", "gt", vim.diagnostic.open_float)
