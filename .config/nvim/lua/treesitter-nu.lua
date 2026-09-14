require("nvim-treesitter").setup({})

local skipped_filetypes = {
    "bash",
}

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        if not vim.tbl_contains(skipped_filetypes, vim.bo[args.buf].filetype) then
            pcall(vim.treesitter.start, args.buf)
        end
    end,
})
