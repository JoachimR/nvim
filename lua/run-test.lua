local function get_current_buffer_info()
	local bufnr = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local directory = vim.fn.fnamemodify(filename, ":p:h")
	return directory, filename
end

local testCmd = "pnpm test"

local function save_and_run_test()
	local directory, filename = get_current_buffer_info()
	-- save file
	vim.cmd("w")

	-- run test of file
	local command = 'TermExec direction=vertical size=80 cmd="' .. testCmd .. " " .. filename .. '" dir=' .. directory
	vim.cmd(command)
end

vim.keymap.set("n", "<leader>oo", save_and_run_test, { silent = true, noremap = true, desc = "Test file" })
