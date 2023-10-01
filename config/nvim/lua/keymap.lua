-- Map some cool keys
local function map(mode, lhs, rhs, opts)
	local keys = require("lazy.core.handler").handlers.keys
	---@cast keys LazyKeysHandler
	-- do not create the keymap if a lazy keys handler exists
	if not keys.active[keys.parse({ lhs, mode = mode }).id] then
		opts = opts or {}
		opts.silent = opts.silent ~= false
		if opts.remap and not vim.g.vscode then
			opts.remap = nil
		end
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

local opts = { silent = true, remap = true, noremap = false }

-- Insert blank line before/after cursor and restore position
map("n", "[<space>", "mlO<Esc>`l", opts)
map("n", "]<space>", "mlo<Esc>`l", opts)

map("n", "<C-s>", ":w<CR>", opts)

map("i", "<C-b>", '<C-o>h', opts)
map('i', '<C-f>', '<C-o>a', opts)

map("i", "<M-b>", '<C-o>b', opts)
map("i", "<M-f>", '<C-o>e<C-o>a', opts)

map("i", "<S-Tab>", '<C-o>b', opts)
map("i", "<Tab>", '<C-o>w<C-o>i', opts)

map("i", "<M-C-b>", '<C-o>B', opts)
map("i", "<M-C-f>", '<C-o>E<C-o>a', opts)

map('i', '<M-C-j>', '<C-o>gj', opts)
map('i', '<M-C-k>', '<C-o>gk', opts)


-- escape to clear search
map({ "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
-- Double escape to enter normal mode in a terminal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Indent visual selection and re-select
map("v", "<", "<gv")
map("v", ">", ">gv")

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Telescope
-- See `:help telescope.builtin`
map('n', '<leader>fr', require('telescope.builtin').oldfiles, { desc = 'Find Recent' })
map('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find Buffer' })
map('n', '<leader>fs', function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
		winblend = 10,
		previewer = true,
	})
end, { desc = 'Find In Buffer' })

map('n', '<leader>fg', require('telescope.builtin').git_files, { desc = 'Find Git Files' })
map('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
map('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Find Help' })
map('n', '<leader>/', require('telescope.builtin').live_grep, { desc = 'Live Grep' })
map('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = 'Find Diagnostic' })
map('n', '<leader>f;', require('telescope.builtin').resume, { desc = 'Resume Search' })
map('n', '<leader>wc', "<cmd>w !diff % -<CR>", { desc = "Diff unsaved buffer content" })

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
