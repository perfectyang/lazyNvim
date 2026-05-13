require("perfectyang.core.options")
require("perfectyang.core.keymaps")

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
})

-- 自动补全
-- vim.o.autocomplete = true
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(ev)
--     local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
--     if client:supports_method("textDocument/completion") then
--       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--     end
--   end,
-- })
-- vim.opt.complete:append("o")
-- vim.opt.completeopt = { "menuone", "noselect" }
-- vim.o.pumheight = 10
-- vim.o.pumborder = "rounded"

-- local cmp_nvim_lsp = require("cmp_nvim_lsp")
-- local capabilities = cmp_nvim_lsp.default_capabilities()
--
-- local servers = {
--   html = {},
--   cssls = {},
--   tailwindcss = {},
--   svelte = {},
--   ts_ls = {},
--   lua_ls = {},
--   graphql = {},
--   emmet_ls = {},
--   prismals = {},
--   pyright = {},
--   bashls = {},
--   oxlint = {},
--   oxfmt = {},
-- }
--
-- for server, opts in pairs(servers) do
--   vim.lsp.config[server] = vim.tbl_deep_extend("force", {
--     capabilities = capabilities,
--   }, opts)
--   vim.lsp.enable(server)
-- end
