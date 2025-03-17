local M = {}

local state = {
  floating = {
    buf = -1, -- 缓冲区
    win = -1, -- 窗口id
  },
}

-- 存储创建的窗口
M.windows = {}

function M.create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  -- Define window configuration
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal", -- No borders or extra UI elements
    border = "rounded",
  }

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "readonly", true)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)
  vim.api.nvim_win_set_option(win, "relativenumber", true)
  local _win = { buf = buf, win = win }
  state.floating = _win
  table.insert(M.windows, _win)
  return _win
end

function M.toggle_window(tbl)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, tbl.strmap)
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = M.create_floating_window({ buf = buf })
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

function M.get_project_root()
  local git_dir = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  return git_dir ~= "" and git_dir or vim.fn.getcwd()
end

function M.get_current_branch()
  return vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
end

function M.get_project_branch_id()
  local project_root = M.get_project_root()
  local branch = M.get_current_branch()
  return project_root .. ":" .. branch
end

return M
