return {
  "stevearc/oil.nvim",
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" }, -- Customize columns (e.g., "permissions", "size", etc.)
      keymaps = {
        ["<BS>"] = "actions.parent",
        ["<CR>"] = "actions.select",
        ["_"] = "actions.open_cwd",
      },
      view_options = {
        show_hidden = true, -- Show hidden files
      },
    })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional dependency for icons
}
