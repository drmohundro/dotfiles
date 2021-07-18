local function prettier()
	return {
		exe = 'prettier',
		args = { '--stdin-filepath', vim.api.nvim_buf_get_name(0), '--single-quote' },
		stdin = true,
	}
end

require('formatter').setup({
	logging = false,
	filetype = {
		javascript = { prettier },
		json = { prettier },
		html = { prettier },
		rust = {
			-- Rustfmt
			function()
				return {
					exe = 'rustfmt',
					args = { '--emit=stdout' },
					stdin = true,
				}
			end,
		},
		lua = {
			-- stylua - cargo install stylua
			function()
				return {
					exe = 'stylua',
					args = { '--search-parent-directories', '-' },
					stdin = true,
				}
			end,
		},
	},
})
