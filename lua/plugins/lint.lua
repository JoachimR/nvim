return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "oxlint" },
			javascriptreact = { "oxlint" },
			typescript = { "oxlint" },
			typescriptreact = { "oxlint" },
			vue = { "oxlint" },
		}

		-- Prefer project-local oxlint binary when present
		local function resolve_oxlint_cmd()
			local cwd = vim.fn.getcwd()
			local local_bin = cwd .. "/node_modules/.bin/oxlint"
			if vim.fn.executable(local_bin) == 1 then
				return local_bin
			end
			return "oxlint"
		end

		if lint.linters.oxlint then
			lint.linters.oxlint.cmd = resolve_oxlint_cmd()
		end

		local function try_lint()
			-- Skip when oxlint is not available at all
			if vim.fn.executable(resolve_oxlint_cmd()) ~= 1 then
				return
			end
			-- Refresh cmd in case cwd changed since startup
			if lint.linters.oxlint then
				lint.linters.oxlint.cmd = resolve_oxlint_cmd()
			end
			lint.try_lint()
		end

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
			group = vim.api.nvim_create_augroup("UserNvimLint", { clear = true }),
			callback = try_lint,
		})
	end,
}
