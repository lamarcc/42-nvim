return {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1001,
    opts = {
        transparent = true,
        styles = {
            comment = { italic = true },
            keyword = { italic = false, bold = false },
        },
    },
    init = function()
        vim.cmd.colorscheme("kanagawa-paper-ink") -- ink (dark) ou canvas (light)
    end,
}
