local M = {}

-- 1. 初始化一个 SQLite 数据库对象
local db_path = vim.fn.expand("~/Downloads")

local sqlite = require("sqlite")

local db = sqlite({
  uri = db_path .. "/pnotes.db",
  notes = {
    content = { "text" },
    id = { "text", primary = true, unique = true },
  },
})

local data = db.notes

function M.add_note(brand, content)
  db:with_open(function()
    -- check if entry exists in db
    -- local res = db:eval("SELECT * FROM notes WHERE id = :brand", { id = brand })
    -- print(type(res))
    -- -- if result is empty (eval returns boolean), proceed to insertion
    -- if type(res) ~= "boolean" then
    --   -- remove entry from db so it can be moved to first position
    --   db:eval("DELETE FROM notes WHERE id = :brand", { id = brand })
    -- end
    -- 3. 插入一些数据
    print("插入一些数据")
    db:eval("INSERT INTO notes (id, content) VALUES (:id, :content)", {
      id = brand,
      content = content,
    })
  end)
end

function M.get_data()
  return data
end

-- 获取指定brand的数据
function M.select_data(brand)
  local e = db:with_open(function()
    return db:select("notes", {
      where = { id = brand },
      limit = 1,
    })[1]
  end)

  if e then
    return e.content
  else
    return ""
  end
end

return M
