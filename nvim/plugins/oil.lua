return {
  "stevearc/oil.nvim",
  config = function()
    local detail = false

    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" }, -- Default column setup
      keymaps = {
        ["<BS>"] = "actions.parent",
        ["<CR>"] = "actions.select",
        ["_"] = "actions.open_cwd",
        ["gd"] = {
          desc = "Toggle file detail view",
          callback = function()
            detail = not detail
            if detail then
              require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
            else
              require("oil").set_columns({ "icon" })
            end
          end,
        },
      },
      view_options = {
        show_hidden = true, -- Show hidden files
      },
    })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional dependency for icons
}
