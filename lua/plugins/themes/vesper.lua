return {
    "datsfilipe/vesper.nvim",
    lazy = false,
    priority = 1001,
    config = function()
        require("vesper").setup({
            transparent = false,
            italics = {
                comments = true,
                keywords = false,
                functions = false,
                strings = false,
                variables = false,
            },
        })
        vim.cmd.colorscheme("vesper")
    end,
}
