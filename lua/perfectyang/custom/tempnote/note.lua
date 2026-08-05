local M = {}

local db = require("perfectyang.custom.tempnote.db")

M.project_branch_buffers = {}
M.buffer_project_branch_ids = {}
M.float_win = nil
M.is_clearing_notes = false

function M.get_legacy_note_path(project_branch_id)
  return vim.fn.expand(vim.fn.stdpath("cache") .. "/git_notes/" .. vim.fn.sha256(project_branch_id) .. ".txt")
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

function M.get_project_branch_buffer()
  local project_branch_id = M.get_project_branch_id()

  if M.project_branch_buffers[project_branch_id] then
    return M.project_branch_buffers[project_branch_id]
  else
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, "GitNotes: " .. project_branch_id)

    -- set buffer type same as current window for syntax highlighting
    -- local current_filetype = vim.bo.filetype
    -- vim.api.nvim_set_option_value("filetype", current_filetype, { buf = bufnr })

    vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

    M.project_branch_buffers[project_branch_id] = bufnr
    M.buffer_project_branch_ids[bufnr] = project_branch_id

    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = bufnr,
      callback = function()
        M.save_buffer_content(bufnr, project_branch_id)
      end,
    })

    M.load_buffer_content(bufnr, project_branch_id)

    return bufnr
  end
end

function M.save_buffer_content(bufnr, project_branch_id)
  if not project_branch_id or project_branch_id == "" then
    return
  end

  local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  db.add_note(project_branch_id, table.concat(content, "\n"))
  vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

function M.load_buffer_content(bufnr, project_branch_id)
  local content = db.select_data(project_branch_id)

  if content == "" then
    local file_path = M.get_legacy_note_path(project_branch_id)
    if vim.fn.filereadable(file_path) == 1 then
      local legacy_content = vim.fn.readfile(file_path)
      content = table.concat(legacy_content, "\n")
      db.add_note(project_branch_id, content)
    end
  end

  if content ~= "" then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n", { plain = true }))
  end

  vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

function M.create_float_win(bufnr)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  }

  M.float_win = vim.api.nvim_open_win(bufnr, true, win_opts)

  vim.api.nvim_win_set_option(M.float_win, "winblend", 10)
  vim.api.nvim_win_set_option(M.float_win, "cursorline", true)
  vim.api.nvim_win_set_option(M.float_win, "relativenumber", true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")
  -- vim.api.nvim_set_option_value("filetype", vim.bo.filetype, { buf = bufnr })

  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "q",
    ':lua require("perfectyang.custom.tempnote.note").close_float_win()<CR>',
    { noremap = true, silent = true }
  )

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(M.float_win),
    callback = function()
      if not M.is_clearing_notes then
        local project_branch_id = M.get_project_branch_id()
        M.save_buffer_content(bufnr, project_branch_id)
      end
      M.float_win = nil
    end,
  })
end

function M.close_float_win()
  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    local bufnr = vim.api.nvim_win_get_buf(M.float_win)
    local project_branch_id = M.get_project_branch_id()
    if not M.is_clearing_notes then
      M.save_buffer_content(bufnr, project_branch_id)
    end
    vim.api.nvim_win_close(M.float_win, true)
    M.float_win = nil
  end
end

function M.cleanup_deleted_branches()
  local current_project = M.get_project_root()
  local current_branches = {}

  local branches = vim.fn.systemlist("git branch --format='%(refname:short)'")
  for _, branch in ipairs(branches) do
    current_branches[current_project .. ":" .. branch] = true
  end

  for project_branch_id, bufnr in pairs(M.project_branch_buffers) do
    local project, branch = project_branch_id:match("(.+):(.+)")
    if project == current_project and not current_branches[project_branch_id] then
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end

      db.delete_note(project_branch_id)

      local file_path = M.get_legacy_note_path(project_branch_id)
      if vim.fn.filereadable(file_path) == 1 then
        vim.fn.delete(file_path)
      end

      M.project_branch_buffers[project_branch_id] = nil
      M.buffer_project_branch_ids[bufnr] = nil
    end
  end
end

function M.clear_notes()
  M.is_clearing_notes = true
  db.clear_notes()

  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.api.nvim_win_close(M.float_win, true)
  end

  local buffers = {}
  for project_branch_id, bufnr in pairs(M.project_branch_buffers) do
    table.insert(buffers, { project_branch_id = project_branch_id, bufnr = bufnr })
  end

  for _, entry in ipairs(buffers) do
    local project_branch_id = entry.project_branch_id
    local bufnr = entry.bufnr

    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    M.project_branch_buffers[project_branch_id] = nil
    M.buffer_project_branch_ids[bufnr] = nil
  end

  M.float_win = nil
  M.is_clearing_notes = false
end

function M.toggle_project_branch_notes()
  M.cleanup_deleted_branches()
  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    M.close_float_win()
  else
    local bufnr = M.get_project_branch_buffer()
    M.create_float_win(bufnr)
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "GitBranchChanged",
  callback = function()
    M.cleanup_deleted_branches()
    if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
      local old_bufnr = vim.api.nvim_win_get_buf(M.float_win)
      local old_project_branch_id = M.buffer_project_branch_ids[old_bufnr]
      M.save_buffer_content(old_bufnr, old_project_branch_id)

      local new_bufnr = M.get_project_branch_buffer()
      vim.api.nvim_win_set_buf(M.float_win, new_bufnr)
    end
  end,
})

return M
