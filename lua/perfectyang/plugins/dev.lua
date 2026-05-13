-- 本地自定义插件开发
return {
  -- {
  --   dir = "~/plugins/present.nvim",
  --   -- config = function()
  --   --   require("present").setup()
  --   -- end,
  -- },
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
}
