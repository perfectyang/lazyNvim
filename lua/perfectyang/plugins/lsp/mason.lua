return {
  "williamboman/mason.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
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

    vim.diagnostic.config({
      virtual_text = {
        spacing = 2,
        source = "if_many",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "if_many",
      },
    })

    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end

      -- nmap("K", vim.lsp.buf.hover, "Hover")
      -- nmap("gD", vim.lsp.buf.declaration, "Go to declaration")
      -- nmap("gi", vim.lsp.buf.implementation, "Go to implementation")
      -- nmap("<leaner>rn", vim.lsp.buf.rename, "Rename")
      -- nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
      -- nmap("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
      --
      -- local ok, builtin = pcall(require, "telescope.builtin")
      -- if ok then
      --   nmap("gr", builtin.lsp_references, "References")
      --   nmap("gd", builtin.lsp_definitions, "Go to definition")
      --   nmap("gt", builtin.lsp_type_definitions, "Go to type definition")
      -- else
      --   nmap("gr", vim.lsp.buf.references, "References")
      --   nmap("gd", vim.lsp.buf.definition, "Go to definition")
      --   nmap("gt", vim.lsp.buf.type_definition, "Go to type definition")
      -- end
    end

    local servers = {
      bashls = {
        filetypes = { "bash", "sh", "zsh" },
      },
      html = {
        filetypes = { "html" },
      },
      cssls = {
        filetypes = { "css", "scss", "less" },
      },
      tailwindcss = {
        filetypes = {
          "html",
          "css",
          "scss",
          "less",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
        },
      },
      svelte = {
        filetypes = { "svelte" },
      },
      vue_ls = {
        filetypes = { "vue" },
      },
      lua_ls = {
        filetypes = { "lua" },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },
      graphql = {
        filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      },
      emmet_ls = {
        filetypes = {
          "html",
          "css",
          "scss",
          "less",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
        },
      },
      prismals = {
        filetypes = { "prisma" },
      },
      pyright = {
        filetypes = { "python" },
      },
      ts_ls = {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
      },
      vtsls = {
        filetypes = { "vue" },
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.stdpath("data")
                    .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        },
      },
    }

    local server_order = {
      "bashls",
      "html",
      "cssls",
      "tailwindcss",
      "svelte",
      "vtsls",
      "vue_ls",
      "lua_ls",
      "graphql",
      "emmet_ls",
      "prismals",
      "pyright",
      "ts_ls",
    }

    for _, server in ipairs(server_order) do
      local opts = servers[server]
      vim.lsp.config[server] = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = on_attach,
      }, opts)
      vim.lsp.enable(server)
    end

    mason_lspconfig.setup({
      ensure_installed = {
        "bashls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "vue_ls",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "ts_ls",
        "vtsls",
      },
      automatic_enable = false,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "oxfmt",
        "oxlint",
        "stylua",
        "eslint_d",
      },
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 12,
    })
  end,
}
