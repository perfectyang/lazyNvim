local M = {
  conf = {},
  zindex = 1,
  windows = {},
}

M.addIndex = function()
  M.zindex = M.zindex + 1
end

M.setup_lib = function(conf)
  M.conf = vim.tbl_deep_extend("force", M.conf, conf)
  M.logger.debug("lib:", vim.inspect(M.conf))
end

local function is_floating(window_id)
  return vim.api.nvim_win_get_config(window_id).relative ~= ""
end

local function is_curr_buf(buffer)
  return vim.api.nvim_get_current_buf() == buffer
end

local logger = {
  debug = function(...)
    if M.conf.debug then
      print("goto-preview:", ...)
    end
  end,
}

M.logger = logger

local run_post_open_hook_function = function(buffer, new_window)
  local success, result = pcall(M.conf.post_open_hook, buffer, new_window)
  logger.debug("post_open_hook call success:", success, result)
end

local run_post_close_hook_function = function(buffer, new_window)
  local success, result = pcall(M.conf.post_close_hook, buffer, new_window)
  logger.debug("post_close_hook call success:", success, result)
end

function M.tablefind(tab, el)
  for index, value in pairs(tab) do
    if value == el then
      return index
    end
  end
end

M.remove_win = function(win)
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_win = vim.api.nvim_get_current_win()

  local success, result = pcall(vim.api.nvim_win_get_var, curr_win, "is-goto-preview-window")

  if success and result == 1 then
    run_post_close_hook_function(curr_buf, curr_win)
  end

  local index = M.tablefind(M.windows, win or vim.api.nvim_get_current_win())
  if index then
    table.remove(M.windows, index)
    -- Focus the previous preview if there is one
    if index > 1 then
      local prev_win = M.windows[index - 1]
      M.addIndex()
      vim.api.nvim_set_current_win(prev_win)
      vim.api.nvim_win_set_config(prev_win, {
        zindex = M.zindex, -- 修改 zindex
      })
    end
  end
end

M.is_window_valid = function(win)
  return vim.api.nvim_win_is_valid(win)
end

M.focus_win = function()
  local first_win = M.windows[#M.windows]
  if M.is_window_valid(first_win) then
    vim.api.nvim_set_current_win(first_win)
    vim.api.nvim_win_set_config(first_win, {
      zindex = M.zindex, -- 修改 zindex
    })
  end
end

M.go_next_win = function(win)
  local index = M.tablefind(M.windows, win or vim.api.nvim_get_current_win())
  local len = #M.windows
  M.addIndex()
  if index then
    if index >= 1 and index < len then
      local prev_win = M.windows[index + 1]
      vim.api.nvim_set_current_win(prev_win)
      vim.api.nvim_win_set_config(prev_win, {
        zindex = M.zindex, -- 修改 zindex
      })
    elseif index == len then
      local first_win = M.windows[1]
      vim.api.nvim_set_current_win(first_win)
      vim.api.nvim_win_set_config(first_win, {
        zindex = M.zindex, -- 修改 zindex
      })
    end
  end
end

M.setup_aucmds = function()
  vim.cmd([[
    augroup goto-preview
      au!
      au WinClosed * lua require('perfectyang.custom.goto.lib').remove_win()
      au BufEnter * lua require('perfectyang.custom.goto.lib').buffer_entered()
      au BufLeave * lua require('perfectyang.custom.goto.lib').buffer_left()
    augroup end
  ]])
end

M.dismiss_preview = function(winnr)
  logger.debug("dismiss_preview", winnr)
  if winnr then
    logger.debug("attempting to close ", winnr)
    pcall(vim.api.nvim_win_close, winnr, true)
  else
    logger.debug("attempting to all preview windows")
    for _, win in ipairs(M.windows) do
      M.close_if_is_goto_preview(win)
    end
  end
end

M.close_if_is_goto_preview = function(win_handle)
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_win = vim.api.nvim_get_current_win()

  local success, result = pcall(vim.api.nvim_win_get_var, win_handle, "is-goto-preview-window")
  if success and result == 1 then
    run_post_close_hook_function(curr_buf, curr_win)
    vim.api.nvim_win_close(win_handle, M.conf.force_close)
  end
end

local function set_title(buffer)
  if vim.fn.has("nvim-0.9.0") == 0 then
    logger.debug("title not supported in this version of neovim")
    return nil
  end

  local rel_filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":~")
  return M.conf.preview_window_title.enable and rel_filepath or nil
end

local function set_title_pos()
  if vim.fn.has("nvim-0.9.0") == 0 then
    logger.debug("title_pos not supported in this version of neovim")
    return nil
  end

  return M.conf.preview_window_title.enable and M.conf.preview_window_title.position or nil
end

local function create_preview_win(buffer, bufpos, zindex, opts)
  local enter = function()
    return opts.focus_on_open or M.conf.focus_on_open or false
  end

  local stack_floating_preview_windows = function()
    return opts.stack_floating_preview_windows or M.conf.stack_floating_preview_windows or false
  end

  local same_file_float_preview = function()
    return opts.same_file_float_preview or M.conf.same_file_float_preview or false
  end

  logger.debug("focus_on_open", enter())
  logger.debug("stack_floating_preview_windows", stack_floating_preview_windows())

  local preview_window
  local curr_win = vim.api.nvim_get_current_win()
  local success, result = pcall(vim.api.nvim_win_get_var, curr_win, "is-goto-preview-window")

  if is_curr_buf(buffer) and not same_file_float_preview() then
    return curr_win
  end

  -- local level = #M.windows -- 当前已有的窗口数，作为新窗口的偏移层次（0-based）
  -- -- 浮动窗口基础尺寸（可根据需求调节）
  -- local base_width = math.floor(vim.o.columns * 0.6)
  -- local base_height = math.floor(vim.o.lines * 0.5)
  -- local width = M.conf.width - level * 2 -- 可选：每层宽度缩小一点，避免完全覆盖
  -- local height = M.conf.height - level * 1
  -- if width < 40 then
  --   width = 40
  -- end
  -- if height < 10 then
  --   height = 10
  -- end
  --
  -- -- 偏移量：每层向右下角移动 3 列、2 行（可根据喜好调整）
  -- local offset_col = level * 4
  -- local offset_row = level * 2
  -- local default_col = math.floor((vim.o.columns - width) / 2)
  -- local default_row = math.floor((vim.o.lines - height) / 2)
  -- local col = default_col + offset_col
  -- local row = default_row + offset_row
  -- -- 边界限制：不超出屏幕右边缘和下边缘
  -- if col + width > vim.o.columns then
  --   col = vim.o.columns - width
  -- end
  -- if row + height > vim.o.lines then
  --   row = vim.o.lines - height
  -- end
  -- if col < 0 then
  --   col = 0
  -- end
  -- if row < 0 then
  --   row = 0
  -- end

  if not stack_floating_preview_windows() and is_floating(curr_win) and success and result == 1 then
    preview_window = curr_win
    vim.api.nvim_win_set_config(preview_window, {
      width = M.conf.width,
      height = M.conf.height,
      border = M.conf.border,
      -- col = col,
      -- row = row,
    })
    vim.api.nvim_win_set_buf(preview_window, buffer)
  else
    preview_window = vim.api.nvim_open_win(buffer, enter(), {
      relative = "win",
      width = M.conf.width,
      height = M.conf.height,
      border = M.conf.border,
      bufpos = bufpos,
      zindex = zindex,
      -- col = col,
      -- row = row,
      win = vim.api.nvim_get_current_win(),
      title = set_title(buffer),
      title_pos = set_title_pos(),
    })

    table.insert(M.windows, preview_window)
  end

  return preview_window
end

M.open_floating_win = function(target, position, opts)
  local buffer = type(target) == "string" and vim.uri_to_bufnr(target) or target
  local bufpos = { vim.fn.line(".") - 1, vim.fn.col(".") } -- FOR relative='win'
  -- local zindex = M.conf.zindex + (vim.tbl_isempty(M.windows) and 0 or #M.windows)
  M.addIndex()
  local zindex = M.zindex

  opts = opts or {}

  local preview_window = create_preview_win(buffer, bufpos, zindex, opts)
  --  给buffer设置绑定的命令
  vim.api.nvim_buf_set_keymap(
    buffer,
    "n",
    "q",
    string.format(':lua require("perfectyang.custom.goto.lib").dismiss_preview(%d)<CR>', preview_window),
    { noremap = true, silent = true }
  )

  if M.conf.opacity then
    vim.api.nvim_set_option_value("winblend", M.conf.opacity, { win = preview_window })
  end
  if not is_curr_buf(buffer) then
    vim.api.nvim_set_option_value("bufhidden", M.conf.bufhidden, { buf = buffer })
  end
  vim.api.nvim_win_set_var(preview_window, "is-goto-preview-window", 1)
  -- vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal,FloatBorder:WinSeparator", { win = preview_window })

  -- logger.debug(vim.inspect({
  --   curr_window = vim.api.nvim_get_current_win(),
  --   preview_window = preview_window,
  --   bufpos = bufpos,
  --   get_config = vim.api.nvim_win_get_config(preview_window),
  --   get_current_line = vim.api.nvim_get_current_line(),
  --   windows = M.windows,
  -- }))

  -- local dismiss = function()
  --   if opts.dismiss_on_move ~= nil then
  --     return opts.dismiss_on_move
  --   else
  --     return M.conf.dismiss_on_move
  --   end
  -- end

  -- Set position of the preview buffer equal to the target position so that correct preview position shows
  vim.api.nvim_win_set_cursor(preview_window, position)

  run_post_open_hook_function(buffer, preview_window)
end

M.buffer_entered = function()
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_win = vim.api.nvim_get_current_win()

  local success, result = pcall(vim.api.nvim_win_get_var, curr_win, "is-goto-preview-window")

  if success and result == 1 then
    logger.debug("buffer_entered was called and will run hook function")
    run_post_open_hook_function(curr_buf, curr_win)
  end
end

M.buffer_left = function()
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_win = vim.api.nvim_get_current_win()

  local success, result = pcall(vim.api.nvim_win_get_var, curr_win, "is-goto-preview-window")

  if success and result == 1 then
    logger.debug("buffer_left was called and will run hook function")
    run_post_close_hook_function(curr_buf, curr_win)
  end
end

local function _open_references_window(val)
  M.open_floating_win(vim.uri_from_fname(val.filename), { val.lnum, val.col })
end

local function open_references_previewer(prompt_title, items)
  local has_telescope, _ = pcall(require, "telescope")

  if has_telescope then
    local pickers = require("telescope.pickers")
    local make_entry = require("telescope.make_entry")
    local telescope_conf = require("telescope.config").values
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local themes = require("telescope.themes")

    local opts = M.conf.references.telescope or themes.get_dropdown({ hide_preview = false })
    local entry_maker = make_entry.gen_from_quickfix(opts)
    local previewer = nil

    if not opts.hide_preview then
      previewer = telescope_conf.qflist_previewer(opts)
    end
    if #items == 1 then
      _open_references_window(items[1])
    else
      pickers
        .new(opts, {
          prompt_title = prompt_title,
          finder = finders.new_table({
            results = items,
            entry_maker = entry_maker,
          }),
          previewer = previewer,
          sorter = telescope_conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              _open_references_window(selection.value)
            end)

            return true
          end,
        })
        :find()
    end
  else
    error("goto_preview_references requires Telescope.nvim")
  end
end

local handle = function(result, opts)
  if not result then
    return
  end

  if type(result) == "table" and #result > 1 then
    logger.debug("multiple results returned:", #result)
    result = { [1] = result[1] }
  end

  local data = result[1] or result

  local target = nil
  local cursor_position = {}

  if vim.tbl_isempty(data) then
    logger.debug("The LSP returned no results. No preview to display.")
    return
  end

  -- target, cursor_position = M.conf.lsp_configs.get_config(data)

  target = data.targetUri or data.uri
  local range = data.targetRange or data.range
  cursor_position = { range.start.line + 1, range.start.character }
  -- return uri, { range.start.line + 1, range.start.character }
  -- opts: focus_on_open, dismiss_on_move, etc.
  M.open_floating_win(target, cursor_position, opts)
end

local handle_references = function(result)
  if not result then
    return
  end
  local items = {}

  vim.list_extend(items, vim.lsp.util.locations_to_items(result, "utf-8") or {})

  open_references_previewer("References", items)
end

local legacy_handler = function(lsp_call, opts)
  return function(_, _, result)
    if lsp_call ~= nil and lsp_call == "textDocument/references" then
      logger.debug("raw result", vim.inspect(result))
      handle_references(result)
    else
      handle(result, opts)
    end
  end
end

local handler = function(lsp_call, opts)
  return function(_, result, _, _)
    if lsp_call ~= nil and lsp_call == "textDocument/references" then
      logger.debug("raw result", vim.inspect(result))
      handle_references(result)
    else
      handle(result, opts)
    end
  end
end

M.get_handler = function(lsp_call, opts)
  local handler_key = lsp_call:gsub("textDocument/", "textDocument/")
  local existing_handler = vim.lsp.handlers[handler_key]

  if existing_handler and type(existing_handler) == "function" then
    local info = debug.getinfo(existing_handler)
    if info and info.nparams == 4 then
      logger.debug("using new handler for " .. lsp_call)
      return handler(lsp_call, opts)
    else
      logger.debug("using legacy handler for " .. lsp_call)
      return legacy_handler(lsp_call, opts)
    end
  end

  return handler(lsp_call, opts)
end

return M
