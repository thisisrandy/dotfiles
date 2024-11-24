-- This is a convenient file for testing plugin issues in isolation. It will
-- create a local dir .repro and create a completely fresh install therein
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
	spec = {
		-- If we want to test in conjunction with LazyVim (or if we're testing
		-- LazyVim itself), uncomment the below { "LazyVim/LazyVim", import =
		-- "lazyvim.plugins" },

		-- Plugins to test go here
	},
})
