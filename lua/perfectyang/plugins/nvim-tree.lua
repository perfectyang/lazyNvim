return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)
      -- custom mappings
      vim.keymap.del("n", "e", { buffer = bufnr })
      vim.keymap.del("n", "x", { buffer = bufnr })
    end

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      open_on_tab = false,
      sync_root_with_cwd = true,
      reload_on_bufenter = true,
      on_attach = my_on_attach,
      -- change folder arrow icons
      -- renderer = {
      --   indent_markers = {
      --     enable = true,
      --   },
      --   icons = {
      --     glyphs = {
      --       folder = {
      --         -- arrow_closed = "", -- arrow when folder is closed
      --         -- arrow_open = "", -- arrow when folder is open
      --       },
      --     },
      --   },
      -- },

      actions = {
        open_file = {
          window_picker = {
            enable = true,
          },
        },
      },
      view = {
        side = "left",
        number = false,
        relativenumber = true,
        width = 30,
        -- float = {
        -- 	enable = true,
        -- 	quit_on_focus_loss = true,
        -- 	open_win_config = {
        -- 		relative = "editor",
        -- 		border = "rounded",
        -- 		width = 40,
        -- 		height = 40,
        -- 		row = 1,
        -- 		col = 1,
        -- 	},
        -- },
        -- mappings = {
        -- 	list = {
        -- 		{ key = "e", action = "" },
        -- 		{ key = "x", action = "" },
        -- 		-- { key = "A", action = "copyName", action_cb = copyName },
        -- 	},
        -- },
      },

      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      hijack_directories = {
        enable = true,
        auto_open = true,
      },

      update_focused_file = {
        enable = true,
        update_root = true,
        ignore_list = {},
      },

      filters = {
        dotfiles = false,
        -- git_clean = false,
        -- no_buffer = false,
        -- custom = {},
        -- exclude = {},
      },

      -- quit_on_open = 1,
      git = {
        enable = true,
        ignore = false,
        timeout = 400,
      },
    })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    -- keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
    -- -- keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
    -- keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
  end,
}
