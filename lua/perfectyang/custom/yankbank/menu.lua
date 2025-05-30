local M = {}

local data = require("perfectyang.custom.yankbank.data")
local helpers = require("perfectyang.custom.yankbank.helpers")

-- default plugin keymaps
local default_keymaps = {
  navigation_next = "j",
  navigation_prev = "k",
  paste = "<CR>",
  paste_back = "P",
  yank = "yy",
  close = { "<Esc>", "q", "<leader>sc" },
}

-- define default yank register
local default_registers = {
  yank_register = "+",
}

-- local YB_OPTS.keymaps = {}

function M.setup()
  -- merge default and options keymap tables
  YB_OPTS.keymaps = vim.tbl_deep_extend("force", default_keymaps, YB_OPTS.keymaps or {})
  -- merge default and options register tables
  YB_OPTS.registers = vim.tbl_deep_extend("force", default_registers, YB_OPTS.registers or {})

  -- check table for number behavior option (prefix or jump, default to prefix)
  YB_OPTS.num_behavior = YB_OPTS.num_behavior or "prefix"
end

--- Container class for YankBank buffer related variables
---@class YankBankBufData
---@field bufnr integer
---@field display_lines table
---@field line_yank_map table
---@field win_id integer

---create new buffer and reformat yank table for ui
---@return YankBankBufData?
function M.create_and_fill_buffer()
  -- stop if yanks or register types table is empty
  if #YB_YANKS == 0 or #YB_REG_TYPES == 0 then
    print(">>>> 杨大帅哥, nothing to show OOOOO!!!!!!!!!!")
    return nil
  end

  -- create new buffer
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- set buffer type same as current window for syntax highlighting
  local current_filetype = vim.bo.filetype
  vim.api.nvim_set_option_value("filetype", current_filetype, { buf = bufnr })

  local display_lines, line_yank_map = data.get_display_lines()

  -- replace current buffer contents with updated table
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display_lines)

  ---@type YankBankBufData
  return {
    bufnr = bufnr,
    display_lines = display_lines,
    line_yank_map = line_yank_map,
    win_id = -1,
  }
end

---Calculate size and create popup window from bufnr
---@param b YankBankBufData
---@return integer
function M.open_window(b)
  -- set maximum window width based on number of lines
  local max_width = 0
  if b.display_lines and #b.display_lines > 0 then
    for _, line in ipairs(b.display_lines) do
      max_width = math.max(max_width, #line)
    end
  else
    max_width = vim.api.nvim_get_option_value("columns", {})
  end

  -- define buffer window width and height based on number of columns
  -- FIX: long enough entries will cause window to go below end of screen
  -- FIX: wrapping long lines will cause entries below to not show in menu (requires scrolling to see)
  -- local width = math.min(max_width, vim.api.nvim_get_option_value("columns", {}) - 4)
  -- local height = math.min(b.display_lines and #b.display_lines or 1, vim.api.nvim_get_option_value("lines", {}) - 10)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  vim.api.nvim_buf_set_option(b.bufnr, "modifiable", false)

  -- open window
  local win_id = vim.api.nvim_open_win(b.bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    -- col = math.floor((vim.api.nvim_get_option_value("columns", {}) - width) / 2),
    -- row = math.floor((vim.api.nvim_get_option_value("lines", {}) - height) / 2),
    border = "rounded",
    style = "minimal",
  })

  -- Highlight current line
  vim.api.nvim_set_option_value("cursorline", true, { win = win_id })

  vim.api.nvim_win_set_option(win_id, "nu", true)

  return win_id
end

--- Set key mappings for the popup window
---@param b YankBankBufData
function M.set_keymaps(b)
  -- key mappings for selection and closing the popup
  local map_opts = { noremap = true, silent = true, buffer = b.bufnr }

  -- popup buffer navigation binds
  -- if YB_OPTS.num_behavior == "prefix" then
  --   vim.keymap.set("n", YB_OPTS.keymaps.navigation_next, function()
  --     local count = vim.v.count1 > 0 and vim.v.count1 or 1
  --     helpers.next_numbered_item(count)
  --     return ""
  --   end, { noremap = true, silent = true, buffer = b.bufnr })
  --   vim.keymap.set("n", YB_OPTS.keymaps.navigation_prev, function()
  --     local count = vim.v.count1 > 0 and vim.v.count1 or 1
  --     helpers.prev_numbered_item(count)
  --     return ""
  --   end, map_opts)
  -- else
  --   vim.keymap.set("n", YB_OPTS.keymaps.navigation_next, helpers.next_numbered_item, map_opts)
  --   vim.keymap.set("n", YB_OPTS.keymaps.navigation_prev, helpers.prev_numbered_item, map_opts)
  -- end
  vim.keymap.set("n", YB_OPTS.keymaps.navigation_next, helpers.next_numbered_item, map_opts)
  vim.keymap.set("n", YB_OPTS.keymaps.navigation_prev, helpers.prev_numbered_item, map_opts)

  -- map number keys to jump to entry if num_behavior is 'jump'
  if YB_OPTS.num_behavior == "jump" then
    for i = 1, YB_OPTS.max_entries do
      vim.keymap.set("n", tostring(i), function()
        vim.api.nvim_win_close(b.win_id, true)
        helpers.smart_paste(YB_YANKS[i], YB_REG_TYPES[i], true)
      end, map_opts)
    end
  end

  -- bind paste behavior
  vim.keymap.set("n", YB_OPTS.keymaps.paste, function()
    local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
    -- use the mapping to find the original yank
    local yankIndex = b.line_yank_map[cursor]
    if yankIndex then
      -- close window upon selection
      vim.api.nvim_win_close(b.win_id, true)
      helpers.smart_paste(YB_YANKS[yankIndex], YB_REG_TYPES[yankIndex], true)
    else
      print("Error: Invalid selection")
    end
  end, map_opts)

  -- paste backwards
  vim.keymap.set("n", YB_OPTS.keymaps.paste_back, function()
    local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
    -- use the mapping to find the original yank
    local yankIndex = b.line_yank_map[cursor]
    if yankIndex then
      -- close window upon selection
      vim.api.nvim_win_close(b.win_id, true)
      helpers.smart_paste(YB_YANKS[yankIndex], YB_REG_TYPES[yankIndex], false)
    else
      print("Error: Invalid selection")
    end
  end, map_opts)

  -- bind yank behavior
  vim.keymap.set("n", YB_OPTS.keymaps.yank, function()
    local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
    local yankIndex = b.line_yank_map[cursor]
    if yankIndex then
      vim.fn.setreg(YB_OPTS.registers.yank_register, YB_YANKS[yankIndex])
      vim.api.nvim_win_close(b.win_id, true)
    end
  end, map_opts)

  -- close popup keybinds
  -- REFACTOR: check if close keybind is string, handle differently
  for _, map in ipairs(YB_OPTS.keymaps.close) do
    vim.keymap.set("n", map, function()
      vim.api.nvim_win_close(b.win_id, true)
    end, map_opts)
  end
end

return M
