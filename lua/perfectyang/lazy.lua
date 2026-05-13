local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local ime_augroup = vim.api.nvim_create_augroup("ImeAugroup", {})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = ime_augroup,
  callback = function()
    vim.cmd(":silent :!macism com.apple.keylayout.ABC")
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = ime_augroup,
  callback = function()
    vim.cmd(":silent :!macism com.apple.keylayout.ABC")
  end,
})

require("lazy").setup({
  { import = "perfectyang.plugins" },
  { import = "perfectyang.plugins.lsp" },
  { import = "perfectyang.plugins.viewRegister" },
  { import = "perfectyang.custom.yankbank.init" },
  { import = "perfectyang.custom.tempnote.init" },
  { import = "perfectyang.custom.goto.init" },
  -- { import = "perfectyang.custom.unless.init" },
  -- {
  --   import = "perfectyang.custom.bookmark.record",
  -- },
  -- { import = "perfectyang.custom.simplemark.init" },
}, {

  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
