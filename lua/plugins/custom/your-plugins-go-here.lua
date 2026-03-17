--[[
-- NOTE: This is where your plugins go! put them in brackets like the following. Lazy will automatically pick them up and install them
-- If you feel like this plugin is useful, feel free to git add commit push and make a pull request from your fork on GitHub.
-- If there is a good, general use-case, I will merge it into the main branch :)
-- There is another example, image-nvim.lua which is a (commented out) example of how plugins can be imported, with options.
]]--

return {
    {
        "voldikss/vim-floaterm",
        config = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_height = 0.8
            vim.g.floaterm_position = "center"
        end,
    },
    {
        "mg979/vim-visual-multi",
    },
}
