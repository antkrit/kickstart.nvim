-- none-ls: inject linters/formatters into Neovim's LSP client
--
-- Ruff was removed from none-ls core builtins; its sources now live in none-ls-extras
-- and are loaded with `require('none-ls.<method>.<name>')`.

vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvimtools/none-ls.nvim',
  'https://github.com/nvimtools/none-ls-extras.nvim',
  'https://github.com/jay-babu/mason-null-ls.nvim',
}

-- Install tools via mason (mason.nvim itself is set up in init.lua)
require('mason-null-ls').setup {
  ensure_installed = { 'ruff' },
  automatic_installation = false,
}

local null_ls = require 'null-ls'
null_ls.setup {
  sources = {
    require 'none-ls.diagnostics.ruff', -- Python linting
    require 'none-ls.formatting.ruff_format', -- Python formatting (`ruff format`)
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() vim.lsp.buf.format { async = true } end, { desc = '[F]ormat buffer' })
