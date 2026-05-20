local lib = require("perfectyang.custom.goto.lib")

local function get_default_telescope_config()
  local ok, themes = pcall(require, "telescope.themes")
  if not ok then
    return {}
  end

  return themes.get_dropdown({
    hide_preview = false,
  })
end

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
    lsp_retry_count = 10, -- Retry count while waiting for LSP clients to attach.
    lsp_retry_delay = 80, -- Retry delay in milliseconds.
    resizing_mappings = true, -- Binds arrow keys to resizing the floating window.
    post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
    references = { -- Configure the telescope UI for slowing the references cycling window.
      telescope = get_default_telescope_config(),
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

local lsp_methods = {
  definition = "textDocument/definition",
  type_definition = "textDocument/typeDefinition",
  implementation = "textDocument/implementation",
  declaration = "textDocument/declaration",
  references = "textDocument/references",
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
  vim.notify(
    "goto-preview: Error calling LSP " .. lsp_call .. ". The current language server might not support it.",
    vim.log.levels.WARN
  )
end

local function get_lsp_clients(bufnr)
  if vim.lsp.get_clients then
    return vim.lsp.get_clients({ bufnr = bufnr })
  end

  return vim.lsp.get_active_clients({ bufnr = bufnr })
end

local function client_supports_method(client, method, bufnr)
  if not client.supports_method then
    return true
  end

  local ok, supported = pcall(client.supports_method, client, method, bufnr)
  if ok then
    return supported
  end

  ok, supported = pcall(client.supports_method, client, method)
  return ok and supported
end

local function get_method_clients(bufnr, method)
  local filetype = vim.bo[bufnr].filetype
  local clients = vim.tbl_filter(function(client)
    return client_supports_method(client, method, bufnr)
  end, get_lsp_clients(bufnr))

  table.sort(clients, function(a, b)
    local priority = {
      typescript = { ts_ls = 1, vtsls = 1, typescript_tools = 1, denols = 2 },
      javascript = { ts_ls = 1, vtsls = 1, typescript_tools = 1, denols = 2 },
      typescriptreact = { ts_ls = 1, vtsls = 1, typescript_tools = 1, denols = 2 },
      javascriptreact = { ts_ls = 1, vtsls = 1, typescript_tools = 1, denols = 2 },
    }
    local filetype_priority = priority[filetype] or {}
    local a_name = a.name or ""
    local b_name = b.name or ""
    local a_priority = filetype_priority[a_name] or 10
    local b_priority = filetype_priority[b_name] or 10

    if a_priority == b_priority then
      return a_name < b_name
    end

    return a_priority < b_priority
  end)

  return clients
end

M.get_encoding = function(bufnr, method)
  bufnr = bufnr or 0
  -- 获取当前缓冲区支持该 LSP method 的第一个客户端
  local clients = method and get_method_clients(bufnr, method) or get_lsp_clients(bufnr)
  local client = clients[1]
  if not client then
    return
  end

  return client.offset_encoding
end

M.getEncoding = M.get_encoding

local function make_position_params(bufnr, client)
  return vim.lsp.util.make_position_params(bufnr, client.offset_encoding)
end

local function has_lsp_result(result)
  if result == nil then
    return false
  end

  if type(result) == "table" then
    return not vim.tbl_isempty(result)
  end

  return true
end

local function request_lsp_location(lsp_call, opts, prepare_params, attempt)
  local bufnr = 0
  attempt = attempt or 1

  local clients = get_method_clients(bufnr, lsp_call)
  if vim.tbl_isempty(clients) then
    if attempt <= M.conf.lsp_retry_count then
      vim.defer_fn(function()
        request_lsp_location(lsp_call, opts, prepare_params, attempt + 1)
      end, M.conf.lsp_retry_delay)
      return
    end

    print_lsp_error(lsp_call)
    return
  end

  local handler = lib.get_handler(lsp_call, opts)

  local function request_client(index)
    local client = clients[index]
    if not client then
      return
    end

    local params = make_position_params(bufnr, client)
    if prepare_params then
      prepare_params(params)
    end

    local ok, request_id = pcall(client.request, client, lsp_call, params, function(err, result, ctx, config)
      if not has_lsp_result(result) then
        request_client(index + 1)
        return
      end

      handler(err, result, ctx, config)
    end, bufnr)

    if not ok or request_id == nil then
      request_client(index + 1)
    end
  end

  request_client(1)
end

--- Preview definition.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_definition = function(opts)
  request_lsp_location(lsp_methods.definition, opts)
end

--- Preview type definition.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_type_definition = function(opts)
  request_lsp_location(lsp_methods.type_definition, opts)
end

--- Preview implementation.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_implementation = function(opts)
  request_lsp_location(lsp_methods.implementation, opts)
end

--- Preview declaration.
--- @param opts table: Custom config
---        • focus_on_open boolean: Focus the floating window when opening it.
---        • dismiss_on_move boolean: Dismiss the floating window when moving the cursor.
--- @see require("goto-preview").setup()
M.lsp_request_declaration = function(opts)
  request_lsp_location(lsp_methods.declaration, opts)
end

M.lsp_request_references = function(opts)
  request_lsp_location(lsp_methods.references, opts, function(params)
    lib.logger.debug("params pre manipulation", vim.inspect(params))
    params.context = params.context or {
      includeDeclaration = true,
    }
    lib.logger.debug("params post manipulation", vim.inspect(params))
  end)
end

M.close_all_win = function(options)
  local windows = vim.api.nvim_tabpage_list_wins(0)
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(windows) do
    local index = lib.tablefind(lib.windows, win)
    if index then
      table.remove(lib.windows, index)
    end

    if not (options and options.skip_curr_window and win == current_win) then
      pcall(lib.close_if_is_goto_preview, win)
    end
  end
end

local function get_active_window()
  local active_win = vim.api.nvim_tabpage_get_win(0)
  return vim.api.nvim_win_is_valid(active_win) and active_win or nil
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
    vim.keymap.set("n", "gl", M.goto_preview_definition, { desc = "Preview definition", silent = true })

    vim.keymap.set("n", "gf", lib.focus_win, { desc = "Focus preview window", silent = true })

    vim.keymap.set("n", "gn", M.go_next_win, { desc = "Next preview window", silent = true })
  end
end

M.apply_resizing_mappings = function()
  if M.conf.resizing_mappings then
    vim.keymap.set("n", "<left>", "<C-w><", { desc = "Decrease window width", silent = true })
    vim.keymap.set("n", "<right>", "<C-w>>", { desc = "Increase window width", silent = true })
    vim.keymap.set("n", "<up>", "<C-w>-", { desc = "Decrease window height", silent = true })
    vim.keymap.set("n", "<down>", "<C-w>+", { desc = "Increase window height", silent = true })
  end
end

M.setup()
return {}
