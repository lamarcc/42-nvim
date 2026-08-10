return {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1001,
    config = function()
        require("rose-pine").setup({
            variant = "moon",
            styles = {
                transparency = true,
            },
        })
        vim.cmd("colorscheme rose-pine")
    end,
}
