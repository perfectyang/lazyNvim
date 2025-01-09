vim.g.mapleader = ";"
local keymap = vim.keymap
local G = vim.g
local opts = { noremap = true, silent = true }
vim.g.skip_ts_context_commentstring_module = true

G.floaterm_keymap_kill = "<F5>"
G.floaterm_keymap_new = "<F6>"
G.floaterm_keymap_toggle = "<F7>"
G.floaterm_keymap_next = "<F8>"
G.floaterm_position = "bottomRight"
G.floaterm_title = "Perfectyang-$1/$2"
G.floaterm_width = 0.8
G.floaterm_height = 0.9
G.floaterm_giteditor = true
G.floaterm_opener = "edit"

-- ---------- 插入模式 ---------- ---
keymap.set("i", "jj", "<ESC>")

keymap.set("n", "j", function(...)
  local count = vim.v.count

  if count == 0 then
    return "gj"
  else
    return "j"
  end
end, { expr = true })

keymap.set("n", "k", function(...)
  local count = vim.v.count

  if count == 0 then
    return "gk"
  else
    return "k"
  end
end, { expr = true })

-- ---------- 视觉模式 ---------- ---
-- 单行或多行移动
-- keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 窗口
-- ---------- 正常模式 ---------- ---
-- keymap.set("n", "<leader>q", ":q!<CR>") -- 垂直新增窗口
keymap.set("n", "<leader>;", ":w!<CR>")
keymap.set("n", "J", "5j")
keymap.set("v", "J", "5j")
keymap.set("n", "K", "5k")
keymap.set("v", "K", "5k")
keymap.set("n", "H", "^")
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
keymap.set("n", "L", "$")
keymap.set("n", "daf", "va{Vd")
keymap.set("n", "yaf", "va{Vy")
keymap.set("n", "yp", "Yp")

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

keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- keymap.set("n", "<Space>", "zc")

-- 分割窗口
keymap.set("n", "<leader>sc", ":close<CR>", opts) -- 关闭窗口
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts) -- 水平新增窗口
keymap.set("n", "<leader>sh", ":split<CR>", opts) -- 垂直新增窗口

-- aff

vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved

keymap.set("n", "gl", "<Plug>(coc-definition)", opts)
-- keymap.set("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
-- keymap.set("n", "gi", "<Plug>(coc-implementation)", {silent = true})
-- keymap.set("n", "gr", "<Plug>(coc-references)", {silent = true})

-- 取消高亮
keymap.set("n", "<CR>", ":nohl<CR>", opts)

-- 切换buffer
keymap.set("n", "<leader>n", ":bnext<CR>", opts)
keymap.set("n", "<leader>b", ":bprevious<CR>", opts)
keymap.set("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>", opts)
-- 清除所有buffer页
keymap.set("n", "<leader>c", ":bufdo bd<CR>", opts)
