return {
  {
    "maxmx03/fluoromachine.nvim",
    config = function()
      local fm = require("fluoromachine")

      fm.setup({
        glow = false,
        theme = "fluoromachine",
      })

      vim.cmd.colorscheme("fluoromachine")
    end,
  },
}
