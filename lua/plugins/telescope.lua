return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.2",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					path_display = { len = 2 },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
						},
					},
				},
			})

			telescope.load_extension("fzf")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ft", function()
				builtin.colorscheme({ enable_preview = true })
			end, {})
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
			vim.keymap.set("n", "<leader>f<CR>", builtin.resume, {})
			vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})

			vim.keymap.set("n", "<leader>fk", function()
				require("telescope.builtin").keymaps()
			end, {})

			vim.keymap.set("n", "<leader>gt", function()
				builtin.diagnostics({ bufnr = 0 })
			end, {})

			-- leader (not bare gr/gd): bare gr conflicts with neovim 0.11's
			-- built-in grr/gri/grn/gra prefix, causing a timeout + stray input.
			-- dedupe: with both vue_ls and vtsls attached, each client returns the
			-- same definition, so builtin.lsp_definitions shows duplicates. We merge
			-- results from all clients and drop identical file:line:col entries.
			vim.keymap.set("n", "<leader>gd", function()
				local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
				local encoding = clients[1] and clients[1].offset_encoding or "utf-16"
				local params = vim.lsp.util.make_position_params(0, encoding)
				vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results)
					local locations = {}
					for _, res in pairs(results) do
						local r = res.result
						if r then
							vim.list_extend(locations, vim.islist(r) and r or { r })
						end
					end
					if vim.tbl_isempty(locations) then
						vim.notify("No definitions found", vim.log.levels.INFO)
						return
					end

					local items = vim.lsp.util.locations_to_items(locations, encoding)
					local seen, deduped = {}, {}
					for _, item in ipairs(items) do
						local key = item.filename .. ":" .. item.lnum .. ":" .. item.col
						if not seen[key] then
							seen[key] = true
							table.insert(deduped, item)
						end
					end

					if #deduped == 1 then
						-- single definition: jump straight there, no picker
						local it = deduped[1]
						vim.cmd("edit " .. vim.fn.fnameescape(it.filename))
						vim.api.nvim_win_set_cursor(0, { it.lnum, it.col - 1 })
						return
					end

					require("telescope.pickers")
						.new({}, {
							prompt_title = "LSP Definitions",
							finder = require("telescope.finders").new_table({
								results = deduped,
								entry_maker = require("telescope.make_entry").gen_from_quickfix({}),
							}),
							sorter = require("telescope.config").values.generic_sorter({}),
							previewer = require("telescope.config").values.qflist_previewer({}),
						})
						:find()
				end)
			end, {})

			-- NOTE on cross-package .vue references: vtsls loads each TS project
			-- (frontend app) lazily — only once a file inside it has been opened.
			-- This monorepo has no root tsconfig/project references linking the
			-- apps to the shared packages, so a references query from a shared
			-- package (e.g. @bryter/module) will NOT include .vue usages in an app
			-- you haven't opened yet this session. Workaround: open any file in the
			-- target app once, then <leader>gr finds its references. (Preloading all
			-- app projects up front was tried and made vtsls choke; not worth it.)

			-- Grouped LSP references: production refs first, then index.ts,
			-- then test files. Each entry is tagged [prod]/[idx]/[test].
			local function ref_category(path)
				if path:match("[/\\]__tests__[/\\]") or path:match("%.test%.[%w]+$") or path:match("%.spec%.[%w]+$") then
					return 3, "test"
				elseif path:match("[/\\]index%.[%w]+$") then
					return 2, "idx"
				end
				return 1, "prod"
			end

			local function run_references()
				local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/references" })
				local encoding = clients[1] and clients[1].offset_encoding or "utf-16"
				-- remember where we called from, to drop the self-reference
				local origin_file = vim.api.nvim_buf_get_name(0)
				local origin_line = vim.api.nvim_win_get_cursor(0)[1]
				local params = vim.lsp.util.make_position_params(0, encoding)
				params.context = { includeDeclaration = true }
				vim.lsp.buf_request_all(0, "textDocument/references", params, function(results)
					local locations = {}
					for _, res in pairs(results) do
						for _, loc in ipairs(res.result or {}) do
							table.insert(locations, loc)
						end
					end
					if vim.tbl_isempty(locations) then
						vim.notify("No references found", vim.log.levels.INFO)
						return
					end

					local items = vim.lsp.util.locations_to_items(locations, encoding)
					items = vim.tbl_filter(function(item)
						return not (item.filename == origin_file and item.lnum == origin_line)
					end, items)
					if vim.tbl_isempty(items) then
						vim.notify("No other references found", vim.log.levels.INFO)
						return
					end
					for _, item in ipairs(items) do
						local rank, label = ref_category(item.filename)
						item._rank = rank
						item._label = label
					end
					table.sort(items, function(a, b)
						if a._rank ~= b._rank then
							return a._rank < b._rank
						end
						if a.filename ~= b.filename then
							return a.filename < b.filename
						end
						return a.lnum < b.lnum
					end)

					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values

					pickers
						.new({}, {
							prompt_title = "LSP References (grouped)",
							finder = finders.new_table({
								results = items,
								entry_maker = function(item)
									local short = vim.fn.fnamemodify(item.filename, ":.")
									local display = ("[%s] %s:%d:%d  %s"):format(
										item._label,
										short,
										item.lnum,
										item.col,
										vim.trim(item.text or "")
									)
									return {
										value = item,
										display = display,
										ordinal = item._rank .. " " .. short .. " " .. (item.text or ""),
										filename = item.filename,
										lnum = item.lnum,
										col = item.col,
									}
								end,
							}),
							sorter = conf.generic_sorter({}),
							previewer = conf.qflist_previewer({}),
						})
						:find()
				end)
			end

			vim.keymap.set("n", "<leader>gr", run_references, {})
		end,
	},
}
