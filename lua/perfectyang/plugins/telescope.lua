return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    local function f_live_grep()
      -- local config_data = vim.g.scratch_config
      if not telescope_status then
        vim.notify("ScrachOpenFzf needs telescope.nvim")
        return
      end

      telescope_builtin.live_grep({
        -- cwd = get_project_root(),
      })
    end

    local function f_find_files()
      if not telescope_status then
        vim.notify(
          'ScrachOpen needs telescope.nvim or you can just add `"use_telescope: false"` into your config file ot use native select ui'
        )
        return
      end
      telescope_builtin.find_files({
        -- cwd = get_project_root(),
      })
    end

    -- set keymaps

    vim.keymap.set({ "n", "t", "i" }, "<leader>fc", f_live_grep)
    vim.keymap.set({ "n", "t", "i" }, "<leader>ff", f_find_files)

    -- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    -- keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    -- keymap.set("n", "<leader>fc", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    -- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    -- keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
