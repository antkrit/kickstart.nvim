-- Claude Code in a toggleable terminal split on the right
--
-- Hiding the window keeps the terminal buffer (and the running `claude` session) alive,
-- so showing it again restores everything as it was.

local WIDTH_RATIO = 0.3

local state = { buf = nil, win = nil }

local function is_open() return state.win ~= nil and vim.api.nvim_win_is_valid(state.win) end

local function width() return math.floor(vim.o.columns * WIDTH_RATIO) end

local function start_terminal()
  -- `jobstart(..., { term = true })` takes over the *current* buffer, so give it a fresh one
  -- (otherwise the file shown in the split would be turned into the terminal)
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.fn.jobstart({ 'claude' }, { term = true })
  vim.bo[state.buf].bufhidden = 'hide' -- keep the session alive while the window is hidden
  vim.bo[state.buf].buflisted = false

  local map = function(lhs, rhs, desc) vim.keymap.set('t', lhs, rhs, { buffer = state.buf, desc = desc }) end
  -- Claude Code uses <Esc><Esc> itself, so pass it through instead of leaving terminal mode.
  -- Use <C-\><C-n> to get to normal mode in this buffer.
  map('<Esc><Esc>', '<Esc><Esc>', 'Send <Esc><Esc> to Claude Code')
  map('<C-h>', '<C-\\><C-n><C-w>h', 'Move focus to the left window')

  -- Focusing the window from normal mode (e.g. <C-l>) would leave it in normal mode,
  -- where you can only scroll. Go straight back to terminal mode so you can type.
  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = state.buf,
    callback = function() vim.cmd.startinsert() end,
  })

  -- Drop the buffer when `claude` exits, so the next toggle starts a fresh session
  vim.api.nvim_create_autocmd('TermClose', {
    buffer = state.buf,
    once = true,
    callback = function(args)
      state.buf = nil
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then vim.api.nvim_buf_delete(args.buf, { force = true }) end
      end)
    end,
  })
end

local function open()
  vim.cmd 'botright vsplit'
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(state.win, width())
  vim.wo[state.win].winfixwidth = true
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = 'no'

  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_win_set_buf(state.win, state.buf)
  else
    start_terminal()
  end
  vim.cmd.startinsert()
end

local function hide()
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    vim.notify('Claude Code is the only window; not hiding it', vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_hide(state.win)
  state.win = nil
end

local function toggle()
  if is_open() then
    hide()
  else
    open()
  end
end

vim.keymap.set('n', '<leader>ac', toggle, { desc = '[A]I: toggle [C]laude Code' })
vim.keymap.set({ 'n', 't' }, '<C-q>', toggle, { desc = 'Toggle Claude Code' })

-- Keep the split at ~30% when the Neovim window is resized
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('custom-claude-code', { clear = true }),
  callback = function()
    if is_open() then vim.api.nvim_win_set_width(state.win, width()) end
  end,
})
