return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    local on_attach = function(_, bufnr)
      -- local nmap = function(keys, func, desc)
      --   vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
      -- end
      --
      -- nmap("K", vim.lsp.buf.hover, "Hover")
      -- nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
      -- nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
      -- nmap("gd", vim.lsp.buf.definition, "Goto Definition")
      -- nmap("gD", vim.lsp.buf.declaration, "Goto Declaration")
      -- nmap("gi", vim.lsp.buf.implementation, "Goto Implementation")
      -- nmap("gr", require("telescope.builtin").lsp_references, "References")
    end

    vim.lsp.config.bashls = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "bash", "sh", "zsh" },
    }

    vim.lsp.config.html = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html" },
    }

    vim.lsp.config.cssls = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "css", "scss", "less" },
    }

    vim.lsp.config.tailwindcss = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "css", "scss", "less" },
    }

    vim.lsp.config.svelte = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "svelte" },
    }

    vim.lsp.config.lua_ls = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "lua" },
    }

    vim.lsp.config.graphql = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "graphql" },
    }

    vim.lsp.config.emmet_ls = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "javascriptreact", "typescriptreact" },
    }

    vim.lsp.config.prismals = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "prisma" },
    }

    vim.lsp.config.pyright = {
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "python" },
    }

    vim.lsp.config.ts_ls = {
      cmd = { "vtsls", "--stdio" }, -- 启动服务器的命令[reference:0]
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      root_markers = { "package.json", "tsconfig.json", ".git" }, -- 用于确定项目根目录的标志文件[reference:2]
    }

    vim.lsp.enable("bashls")
    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("tailwindcss")
    vim.lsp.enable("svelte")
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("graphql")
    vim.lsp.enable("emmet_ls")
    vim.lsp.enable("prismals")
    vim.lsp.enable("pyright")
    vim.lsp.enable("ts_ls")

    mason_lspconfig.setup({
      ensure_installed = {
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "ts_ls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "eslint_d",
      },
    })
  end,
}
