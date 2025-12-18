return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>tt",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
    },
    {
      "<leader>tg",
      function()
        Snacks.terminal("lazygit")
      end,
      desc = "LazyGit",
    },
  },
}
