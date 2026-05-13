return {
  "williamboman/mason.nvim",
  "mfussenegger/nvim-dap",
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui", -- (可选) 提供调试界面的可视化插件
      "nvim-neotest/nvim-nio", -- nvim-dap-ui的依赖
    },
    config = function()
      require("mason-nvim-dap").setup({

        -- 在此处放置配置选项
      })

      -- local dap, dapui = require("dap"), require("nvim-dap-ui")
      -- dapui.setup()
      -- dap.listeners.after.event_initialized["dapui_config"] = function()
      --   dapui.open()
      -- end
      -- dap.listeners.before.event_terminated["dapui_config"] = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited["dapui_config"] = function()
      --   dapui.close()
      -- end
      --
      -- dap.configurations.python = {
      --   {
      --     type = "debugpy",
      --     request = "launch",
      --     name = "Launch file",
      --     program = "${file}",
      --     pythonPath = function()
      --       return "/usr/bin/python3"
      --     end,
      --   },
      -- }
    end,
  },
}
