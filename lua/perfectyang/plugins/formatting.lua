return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "oxfmt", "oxlint" },
        typescript = { "oxfmt", "oxlint" },
        javascriptreact = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        svelte = { "oxfmt", "oxlint" },
        css = { "oxfmt", "oxlint" },
        html = { "oxfmt", "oxlint" },
        json = { "oxfmt", "oxlint" },
        yaml = { "oxfmt", "oxlint" },
        markdown = { "oxfmt", "oxlint" },
        graphql = { "oxfmt", "oxlint" },
        liquid = { "oxfmt", "oxlint" },
        lua = { "stylua" },
        python = { "isort", "black" },
      },
      formatters = {
        oxlint = {
          timeout = 2000,
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
