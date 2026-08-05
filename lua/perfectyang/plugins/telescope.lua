return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
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

    local history = vim.g.pnvim_live_grep_history or {}
    local history_index = 0

    local function f_live_grep()
      if not telescope_status then
        vim.notify("ScrachOpenFzf needs telescope.nvim")
        return
      end

      local buf = vim.api.nvim_create_buf(false, true)
      local width = 60
      local height = 3
      local ui = vim.api.nvim_list_uis()[1]
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((ui.height - height) / 2),
        col = math.floor((ui.width - width) / 2),
        style = "minimal",
        border = "rounded",
        title = "  Search path (empty for cwd · Tab to complete · ↑↓ for history)  ",
        title_pos = "center",
      })

      vim.bo[buf].buftype = "prompt"
      vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:TelescopeBorder,FloatTitle:TelescopePromptTitle"
      vim.fn.prompt_setprompt(buf, "  ❯ ")

      vim.fn.prompt_setcallback(buf, function(text)
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        local trimmed = vim.trim(text)
        if trimmed ~= "" and history[1] ~= trimmed then
          table.insert(history, 1, trimmed)
          vim.g.pnvim_live_grep_history = history
        end
        history_index = 0
        if trimmed == "" then
          telescope_builtin.live_grep({})
        else
          telescope_builtin.live_grep({ search_dirs = vim.split(trimmed, ",") })
        end
      end)

      vim.fn.prompt_setinterrupt(buf, function()
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        history_index = 0
      end)

      vim.keymap.set("i", "<Tab>", function()
        local line = vim.fn.getline(".")
        local word = line:match("[^%s,>]-$") or ""
        local dir_part, prefix
        if word:match("^.*/$") then
          dir_part = word
          prefix = ""
        else
          dir_part = word:match("^(.*/)") or ""
          prefix = word:match("[^/]*$") or word
        end
        local search_base = dir_part
        if search_base ~= "" and not vim.startswith(search_base, "/") and not vim.startswith(search_base, "~") then
          search_base = "./" .. search_base
        end
        local expanded = vim.fn.expand(search_base)
        local matches = vim.fn.glob(expanded .. prefix .. "*", false, true)
        local dirs = vim.tbl_filter(function(item)
          return vim.fn.isdirectory(item) == 1
        end, matches)
        local dir_names = vim.tbl_map(function(item)
          return item:gsub("^" .. vim.pesc(expanded), "")
        end, dirs)
        if #dir_names == 1 then
          local before = line:sub(1, #line - #word)
          vim.fn.setline(".", before .. dir_part .. dir_names[1] .. "/")
          vim.fn.cursor(0, #before + #dir_part + #dir_names[1] + 2)
        elseif #dir_names > 1 then
          vim.fn.complete(vim.fn.col("."), dir_names)
        end
      end, { buffer = buf })

      vim.keymap.set("i", "<Up>", function()
        if vim.fn.pumvisible() ~= 0 then
          vim.fn.feedkeys(vim.keycode("<C-p>"), "n")
          return
        end
        if #history == 0 then
          return
        end
        history_index = math.min(history_index + 1, #history)
        vim.fn.setline(".", "  ❯ " .. history[history_index])
      end, { buffer = buf })

      vim.keymap.set("i", "<Down>", function()
        if vim.fn.pumvisible() ~= 0 then
          vim.fn.feedkeys(vim.keycode("<C-n>"), "n")
          return
        end
        if history_index <= 1 then
          history_index = 0
          vim.fn.setline(".", "  ❯ ")
        else
          history_index = history_index - 1
          vim.fn.setline(".", "  ❯ " .. history[history_index])
        end
      end, { buffer = buf })

      vim.keymap.set("i", "<Esc>", function()
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        history_index = 0
      end, { buffer = buf })

      vim.cmd("startinsert!")
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

    vim.keymap.set({ "n", "t", "i" }, "<leader>fc", f_live_grep, { desc = "全局查找字符串" })
    vim.keymap.set({ "n", "t", "i" }, "<leader>ff", f_find_files, { desc = "全局查找文件" })

    -- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    -- keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    -- keymap.set("n", "<leader>fc", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    -- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    -- keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
