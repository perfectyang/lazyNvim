local db = require("perfectyang.custom.tempnote.db")

local tmp = vim.fn.tempname() .. ".db"
db.setup(tmp)

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    error(
      string.format("%s\nexpected: %s\nactual: %s", message or "assertion failed", vim.inspect(expected), vim.inspect(actual))
    )
  end
end

db.add_note("/tmp/project:main", "first")
assert_eq(db.select_data("/tmp/project:main"), "first", "reads inserted note")

db.add_note("/tmp/project:main", "second")
assert_eq(db.select_data("/tmp/project:main"), "second", "updates existing note")

assert_eq(db.select_data("/tmp/project:missing"), "", "missing note returns empty string")

db.delete_note("/tmp/project:main")
assert_eq(db.select_data("/tmp/project:main"), "", "deleted note returns empty string")

db.add_note("/tmp/project:main", "main")
db.add_note("/tmp/project:other", "other")
db.clear_notes()
assert_eq(db.select_data("/tmp/project:main"), "", "cleared database removes first note")
assert_eq(db.select_data("/tmp/project:other"), "", "cleared database removes second note")

local note = require("perfectyang.custom.tempnote.note")

local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line one", "line two" })
note.save_buffer_content(bufnr, "/tmp/project:feature")
assert_eq(db.select_data("/tmp/project:feature"), "line one\nline two", "note buffer saves to sqlite")

local loaded_bufnr = vim.api.nvim_create_buf(false, true)
note.load_buffer_content(loaded_bufnr, "/tmp/project:feature")
assert_eq(
  table.concat(vim.api.nvim_buf_get_lines(loaded_bufnr, 0, -1, false), "\n"),
  "line one\nline two",
  "note buffer loads from sqlite"
)

local git_note_bufnr = note.get_project_branch_buffer()
assert_eq(vim.api.nvim_buf_is_valid(git_note_bufnr), true, "git note buffer is created")
note.clear_notes()
local ok, new_git_note_bufnr = pcall(note.get_project_branch_buffer)
assert_eq(ok, true, "git note buffer can be reopened after clearing notes")
assert_eq(vim.api.nvim_buf_is_valid(new_git_note_bufnr), true, "reopened git note buffer is valid")

local legacy_id = "/tmp/project:legacy"
local legacy_path = note.get_legacy_note_path(legacy_id)
vim.fn.mkdir(vim.fn.fnamemodify(legacy_path, ":h"), "p")
vim.fn.writefile({ "legacy one", "legacy two" }, legacy_path)

local legacy_bufnr = vim.api.nvim_create_buf(false, true)
note.load_buffer_content(legacy_bufnr, legacy_id)
assert_eq(
  table.concat(vim.api.nvim_buf_get_lines(legacy_bufnr, 0, -1, false), "\n"),
  "legacy one\nlegacy two",
  "legacy file loads"
)
assert_eq(db.select_data(legacy_id), "legacy one\nlegacy two", "legacy file migrates to sqlite")

vim.fn.delete(legacy_path)
vim.fn.delete(tmp)
