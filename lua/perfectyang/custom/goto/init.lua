local lib = require("perfectyang.custom.goto.lib")

local M = {
  conf = {
    width = 80, -- Width of the floating window
    height = 80, -- Height of the floating window
    border = {
      { "╔", "FloatBorder" },
      { "═", "FloatBorder" },
      { "╗", "FloatBorder" },
      { "║", "FloatBorder" },
      { "╝", "FloatBorder" },
      { "═", "FloatBorder" },
      { "╚", "FloatBorder" },
      { "║", "FloatBorder" },
    }, -- Border characters of the floating window
    default_mappings = true, -- Bind default mappings
    debug = false, -- Print debug information
    opacity = 10, -- 0-100 opacity level of the floating window where 100 is fully transparent.
    resizing_mappings = true, -- Binds arrow keys to resizing the floating window.
    post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
    references = { -- Configure the telescope UI for slowing the references cycling window.
      telescope = require("telescope.themes").get_dropdown({
        hide_preview = false,
      }),
      -- telescope = require("telescope.themes").get_cursor({ hide_preview = false }),
    },
    lsp_configs = {
      -- Lsp result configs
      get_config = function(data)
        lib.logger.debug("data from the lsp", vim.inspect(data))

        local uri = data.targetUri or data.uri
        local range = data.targetRange or data.range

        return uri, { range.start.line + 1, range.start.character }
      end,
    },
    focus_on_open = true, -- Focus the floating window when opening it.
    dismiss_on_move = true, -- Dismiss the floating window when moving the cursor.
    force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
    bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
    stack_floating_preview_windows = true, -- Whether to nest floating windows
    same_file_float_preview = true, -- Whether to open a new floating window for a reference within the current file
    preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
    zindex = 1, -- Starting zindex for the stack of floating windows
  },
}

M.setup = function(conf)
  conf = conf or {}
  M.conf = vim.tbl_deep_extend("force", M.conf, conf)
  lib.logger.debug("non-lib:", vim.inspect(M.conf))
  lib.setup_lib(M.conf)
  lib.setup_aucmds()

  if M.conf.default_mappings then
    M.apply_default_mappings()
  end
  if M.conf.resizing_mappings then
    M.apply_resizing_mappings()
  end
end

local function print_lsp_error(lsp_call)
  print("goto-preview: Error calling LSP " .. lsp_call .. ". The current language lsp might not support it.")
end
M.getEncoding = function()
  -- 获取当前缓冲区（编号0）的第一个LSP客户端
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  if not client then
    -- 如果提示 "client is nil"，说明LSP还未成功连接，后续操作理应中止
    return
  end
  -- 获取该客户端支持的位置编码，如 "utf-16"
  local encoding = client.offset_encoding
  return encoding
end

--- Preview definition.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_definition = function(opts)
  local params = vim.lsp.util.make_position_params(0, M.getEncoding())
  local lsp_call = "textDocument/definition"
  local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, params, lib.get_handler(lsp_call, opts))
  if not success then
    print_lsp_error(lsp_call)
  end
end

--- Preview type definition.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_type_definition = function(opts)
  local params = vim.lsp.util.make_position_params(0, M.getEncoding())
  local lsp_call = "textDocument/typeDefinition"
  local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, params, lib.get_handler(lsp_call, opts))
  if not success then
    print_lsp_error(lsp_call)
  end
end

--- Preview implementation.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_implementation = function(opts)
  local params = vim.lsp.util.make_position_params(0, M.getEncoding())
  local lsp_call = "textDocument/implementation"
  local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, params, lib.get_handler(lsp_call, opts))
  if not success then
    print_lsp_error(lsp_call)
  end
end

--- Preview declaration.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_declaration = function(opts)
  local params = vim.lsp.util.make_position_params(0, M.getEncoding())
  local lsp_call = "textDocument/declaration"
  local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, params, lib.get_handler(lsp_call, opts))
  if not success then
    print_lsp_error(lsp_call)
  end
end

M.lsp_request_references = function(opts)
  local params = vim.lsp.util.make_position_params(0, M.getEncoding())

  lib.logger.debug("params pre manipulation", vim.inspect(params))
  if not params.context then
    params.context = {
      includeDeclaration = true,
    }
  end
  lib.logger.debug("params post manipulation", vim.inspect(params))

  local lsp_call = "textDocument/references"
  local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, params, lib.get_handler(lsp_call, opts))
  if not success then
    print_lsp_error(lsp_call)
  end
end

M.close_all_win = function(options)
  local windows = vim.api.nvim_tabpage_list_wins(0)

  for _, win in pairs(windows) do
    local index = lib.tablefind(lib.windows, win)
    if index then
      table.remove(lib.windows, index)
    end

    if options and options.skip_curr_window then
      if win ~= vim.api.nvim_get_current_win() then
        pcall(lib.close_if_is_goto_preview, win)
      end
    else
      pcall(lib.close_if_is_goto_preview, win)
    end
  end
end

local function get_active_window()
  -- local current_tabpage = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local active_win = vim.api.nvim_tabpage_get_win(0)

  -- 验证活动窗口是否在窗口列表中
  for _, win in ipairs(wins) do
    if win == active_win then
      return active_win
    end
  end
  return active_win
end

M.go_next_win = function()
  local win = get_active_window()
  if win then
    lib.go_next_win(win)
  else
    lib.go_next_win()
  end
end

M.remove_win = lib.remove_win
M.buffer_entered = lib.buffer_entered
M.buffer_left = lib.buffer_left
M.dismiss_preview = lib.dismiss_preview
M.goto_preview_definition = M.lsp_request_definition
M.goto_preview_type_definition = M.lsp_request_type_definition
M.goto_preview_implementation = M.lsp_request_implementation
M.goto_preview_declaration = M.lsp_request_declaration
M.goto_preview_references = M.lsp_request_references
-- Mappings

M.apply_default_mappings = function()
  if M.conf.default_mappings then
    vim.keymap.set("n", "gl", M.goto_preview_definition, { desc = "Preview definition" })

    vim.keymap.set("n", "gf", lib.focus_win, { desc = "Preview definition" })

    vim.keymap.set("n", "gn", M.go_next_win, { noremap = true })
  end
end

M.apply_resizing_mappings = function()
  if M.conf.resizing_mappings then
    vim.keymap.set("n", "<left>", "<C-w><", { noremap = true })
    vim.keymap.set("n", "<right>", "<C-w>>", { noremap = true })
    vim.keymap.set("n", "<up>", "<C-w>-", { noremap = true })
    vim.keymap.set("n", "<down>", "<C-w>+", { noremap = true })
  end
end

M.setup()
return {}
