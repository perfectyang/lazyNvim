local M = {}

local sqlite = require("sqlite")

local db
local data

local function default_db_path()
  local dir = vim.fn.stdpath("data") .. "/tempnote"
  vim.fn.mkdir(dir, "p")
  return dir .. "/pnotes.db"
end

local function open_db(uri)
  db = sqlite({
    uri = uri,
    notes = {
      id = { "text", primary = true, unique = true, required = true },
      content = { "text", required = true },
      updated_at = { "integer", required = true, default = 0 },
    },
  })
  data = db.notes
end

function M.setup(uri)
  open_db(vim.fn.expand(uri or default_db_path()))
end

M.setup()

function M.add_note(id, content)
  db:with_open(function()
    db:eval(
      [[
        INSERT INTO notes (id, content, updated_at)
        VALUES (:id, :content, :updated_at)
        ON CONFLICT(id) DO UPDATE SET
          content = excluded.content,
          updated_at = excluded.updated_at
      ]],
      {
        id = id,
        content = content,
        updated_at = os.time(),
      }
    )
  end)
end

function M.get_data()
  return data
end

function M.select_data(id)
  local e = db:with_open(function()
    return db:select("notes", {
      where = { id = id },
      limit = 1,
    })[1]
  end)

  if e then
    return e.content
  else
    return ""
  end
end

function M.delete_note(id)
  return db:with_open(function()
    return db:eval("DELETE FROM notes WHERE id = :id", { id = id })
  end)
end

function M.clear_notes()
  return db:with_open(function()
    return db:eval("DELETE FROM notes")
  end)
end

return M
