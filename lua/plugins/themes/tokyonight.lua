return {
    "slugbyte/lackluster.nvim",
    priority = 1000,
    config = function()
        require("lackluster").setup({
            tweak_background = {
                normal = 'none', -- transparent
            },
        })
        vim.cmd.colorscheme("lackluster")
    end,
}
