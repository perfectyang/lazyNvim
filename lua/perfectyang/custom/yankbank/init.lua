local M = {}

-- define global variables
YB_YANKS = {}
YB_REG_TYPES = {}
YB_PINS = {}
YB_OPTS = {}

-- local imports
local menu = require("perfectyang.custom.yankbank.menu")
local clipboard = require("perfectyang.custom.yankbank.clipboard")
local persistence = require("perfectyang.custom.yankbank.persistence")

-- default plugin options
local default_opts = {
  max_entries = 100,
  sep = "",
  focus_gain_poll = true,
  num_behavior = "jump",
  registers = {
    yank_register = "+",
  },
  debug = true,
  keymaps = {
    paste = "<CR>",
    paste_back = "P",
    navigation_next = "J",
    navigation_prev = "K",
  },
  persist_type = "sqlite",
  db_path = vim.fn.expand("~/.local/share/pnvim/databases"),
}

local state = {
  floating = {
    buf_data = nil, -- 缓冲区
    win = -1, -- 窗口id
  },
}

local function zoom()
  if vim.api.nvim_win_is_valid(state.floating.win) then
    vim.api.nvim_set_current_win(state.floating.win)
  end
end

--- wrapper function for main plugin functionality
local function show_yank_bank()
  YB_YANKS = persistence.get_yanks() or YB_YANKS
  -- initialize buffer and populate bank
  local buf_data = menu.create_and_fill_buffer()
  if not buf_data then
    return
  end

  -- open popup window
  buf_data.win_id = menu.open_window(buf_data)
  state.floating.win = buf_data.win_id

  -- set popup keybinds
  menu.set_keymaps(buf_data)
end

-- plugin setup
---@param opts? table
function M.setup(opts)
  -- merge opts with default options table
  YB_OPTS = vim.tbl_deep_extend("keep", opts or {}, default_opts)

  -- set up menu keybinds from defafaults and YB_OPTS.keymaps
  menu.setup()

  -- enable persistence based on opts (needs to be called before autocmd setup)
  YB_YANKS, YB_REG_TYPES, YB_PINS = persistence.setup()

  -- create clipboard autocmds
  clipboard.setup_yank_autocmd()

  -- create user command
  vim.api.nvim_create_user_command("YankBank", function()
    show_yank_bank()
  end, { desc = "Show Recent Yanks" })
end

M.setup({})

vim.keymap.set("n", "<leader>l", show_yank_bank, { noremap = true })
vim.keymap.set("n", "<leader>z", zoom, { noremap = true })
vim.keymap.set("n", "<leader>db", "<cmd>YankBankClearDB<CR>", { noremap = true })

return {}
