return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		local function get_macos_appearance()
			local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
			if not handle then
				return "light"
			end
			local result = handle:read("*a")
			handle:close()
			if result:match("Dark") then
				return "dark"
			else
				return "light"
			end
		end

		local appearance = get_macos_appearance()
		if appearance == "dark" then
			vim.cmd("colorscheme catppuccin-mocha")
		else
			vim.cmd("colorscheme catppuccin-latte")
		end
		-- vim.cmd.colorscheme("catppuccin")
	end,
}
