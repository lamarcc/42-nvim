--[[ 42-Nvim config file ]] --
--
-- 42-Nvim is a neovim configuration, supercharged for 42 Students.
---@diagnostic disable: missing-fields
-- Set Vim settings. Necessary before lazy is run.
require "config.vim_settings"

-- Install lazy.nvim, the package manager.
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

-- Validate that lazy is available.
if not pcall(require, "lazy") then
	vim.api.nvim_echo(
		{ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
		true, {})
	vim.fn.getchar()
	vim.cmd.quit()
end

-- Load Lazy and make sure every plugin is installed.
require "plugins"

-- Load config/init.lua which will load every plugin configuration.
require "config"

-- Launch! :)
if (vim.g.user42 == nil) then
	vim.g.user42 = vim.env.USER
end

vim.notify = require("notify")

local stdpath = vim.fn.stdpath('config')

if not string.find(vim.fn.system("git -C " .. stdpath .. " remote -v"), "upstream") then
	vim.fn.system("git -C " .. stdpath .. " remote add upstream https://github.com/fclivaz42/42-nvim.git")
end

if vim.g.receiveupdates == true then
	vim.loop.spawn('git', {
			args = { '-C', stdpath, 'fetch', 'upstream' },
			stdio = { nil, nil, nil }
		},
		vim.schedule_wrap(function(code)
			if code == 0 then
				local mainc = vim.fn.system('git -C ' .. stdpath .. ' rev-list --count HEAD..upstream/main')

				if mainc ~= '0\n' then
					vim.notify("Update available!", vim.log.levels.WARN, { title = "42-Nvim" })
				end
			else
				vim.notify("Could not fetch upstream for updates.", vim.log.levels.WARN, { title = "42-Nvim" })
			end
		end
		))
end

if (vim.g.user42 ~= "SET YOUR USER UP") then
	vim.notify("Welcome back " .. vim.g.user42 .. "! :)\nUse 'space-T' to switch between themes.", vim.log.levels.INFO,
		{ title = "42-Nvim" })
else
	vim.notify("If you see this you haven't configured your stuff!\nDon't forget to take a peek at your ~/.config/nvim",
		vim.log.levels.ERROR, { title = "42-Nvim" })
end

vim.opt.fillchars = {
  vert = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
  horiz = " ",
  horizup = " ",
  horizdown = " ",
  eob = " ",
}

-- 1. On définit le caractère utilisé pour séparer les fenêtres (ligne continue)
vim.opt.fillchars:append({
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
})

-- 2. On applique une couleur subtile
local function setup_separator()
  -- Utilise une couleur légèrement plus claire que le fond
  local separator_color = "#333333"

  vim.api.nvim_set_hl(0, "WinSeparator", { fg = separator_color, bold = false })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = separator_color, bold = false })
end

-- Applique tout de suite
setup_separator()

-- Re-force l'application si tu changes de thème
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = setup_separator,
})
