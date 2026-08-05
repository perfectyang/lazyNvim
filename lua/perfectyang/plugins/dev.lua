-- 本地自定义插件开发
return {
  {
    dir = "~/plugins/floatterm.nvim",
    config = function()
      require("floatterm").setup()
    end,
  },
  {
    dir = "~/plugins/fire.nvim",
    config = function()
      require("fire").setup({})
    end,
  },
  {
    dir = "~/plugins/search-and-replace.nvim",
    config = function()
      require("search-and-replace").setup({
        visual_mode_keymap = "ff",
        visual_mode_keymap_action = "prompt",
        open_keymap = "<C-p>",
        keys = {
          close = "q",
          toggle = " ",
          select_all = "a",
          select_none = "n",
          undo = "u",
          replace_current = "x",
          replace_selected = "r",
          replace_all = "A",
          edit_search = "s",
          edit_replace = "p",
          edit_glob = "g",
          rerun = "<C-r>",
          open_file = "o",
          activate = "<CR>",
          run = "R", -- 运行搜索
          copy_path = "y",
          focus_preview = "<C-l>",
          focus_picker = "<C-h>",
          history = "<leader>h", -- 打开历史条件搜索记录
          confirm = "C", -- 启动一个个确认替换模式
          swap = "S", -- 交换搜索和替换
        },
      })
    end,
  },
  -- {
  --   dir = "~/plugins/search-everything.nvim",
  --   config = function()
  --     require("search-everything").setup({})
  --   end,
  -- },

  {
    dir = "~/plugins/substitute.nvim",
    config = function()
      -- {
      --         on_substitute = nil,
      --         yank_substituted_text = false,
      --         preserve_cursor_position = false,
      --         modifiers = nil,
      --         highlight_substituted_text = {
      --           enabled = true,
      --           timer = 500,
      --         },
      --         range = {
      --           prefix = "s",
      --           prompt_current_text = false,
      --           confirm = false,
      --           complete_word = false,
      --           subject = nil,
      --           range = nil,
      --           suffix = "",
      --           auto_apply = false,
      --           cursor_position = "end",
      --         },
      --         exchange = {
      --           motion = false,
      --           use_esc_to_cancel = true,
      --           preserve_cursor_position = false,
      --         },
      --       }
      require("substitute").setup()

      vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
      vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
      vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
      vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
    end,
  },
  {
    dir = "~/plugins/console.nvim",
    config = function()
      -- require("console").setup()
    end,
  },
}
