local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  desc = "Restore Session",
  group = augroup "Session",
  callback = function()
    -- Without delaying the Gitsigns statuscolumn doesn't work on restored buffers... not sure why.
    vim.schedule(function()
      require("persistence").load()
    end)
    -- vim.defer_fn(function()
    --   require("persistence").load()
    -- end, 100)
  end,
  nested = true,
})

-- Highlight when yanking (copying) text
autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = augroup "HighlightYank",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup "LastLocation",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
