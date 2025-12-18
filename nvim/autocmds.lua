-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "yaml",
    callback = function()
        -- Check if Treesitter parser is available for the current buffer
        if require("nvim-treesitter.parsers").has_parser(vim.bo.filetype) then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
        else
            -- Use syntax-based folding if no Treesitter parser is available
            vim.opt_local.foldmethod = "syntax"
        end
    end,
})

