-- diffview.nvim: review all changed files (side-by-side diffs) before committing
--
-- In the view:
--   <Tab>/<S-Tab>  next/previous file
--   -              stage/unstage file (in the file panel)
--   S / U          stage all / unstage all (in the file panel)
--   g?             show all keymaps

vim.pack.add { 'https://github.com/sindrets/diffview.nvim' }

require('diffview').setup {
  enhanced_diff_hl = true, -- Clearer highlighting of deleted/added lines
  use_icons = vim.g.have_nerd_font, -- Icons come from mini.icons, which is only loaded with a nerd font
}

local function toggle()
  if require('diffview.lib').get_current_view() then
    vim.cmd 'DiffviewClose'
  else
    vim.cmd 'DiffviewOpen'
  end
end

vim.keymap.set('n', '<leader>gd', toggle, { desc = '[G]it [D]iff view: toggle (all changes)' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = '[G]it [H]istory of current file' })
