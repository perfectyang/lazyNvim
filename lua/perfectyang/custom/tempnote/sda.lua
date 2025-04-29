local sda = {}

function sda.setup()
  sda.config = {
    history_length = 50,
  }
end

function sda.push(item)
  local copy = vim.deepcopy(vim.g.YANKY_HISTORY)
  table.insert(copy, 1, item)

  if #copy > sda.config.history_length then
    table.remove(copy)
  end

  vim.g.YANKY_HISTORY = copy
end

function sda.get(n)
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return vim.g.YANKY_HISTORY[n]
end

function sda.length()
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return #vim.g.YANKY_HISTORY
end

function sda.all()
  if nil == vim.g.YANKY_HISTORY then
    vim.g.YANKY_HISTORY = {}
  end

  return vim.g.YANKY_HISTORY
end

function sda.clear()
  vim.g.YANKY_HISTORY = {}
end

function sda.delete(index)
  local copy = vim.deepcopy(vim.g.YANKY_HISTORY)
  table.remove(copy, index)

  vim.g.YANKY_HISTORY = copy
end

sda.setup()

vim.keymap.set("n", "<leader>dap", function()
  sda.push({ text = "godod" })
end, { noremap = true })

vim.keymap.set("n", "<leader>dag", function()
  print(sda.get(1).text)
end, { noremap = true })

return sda
