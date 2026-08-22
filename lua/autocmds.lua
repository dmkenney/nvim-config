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

-- Save view when leaving a buffer
autocmd("BufLeave", {
  group = augroup "SaveView",
  callback = function(event)
    if vim.bo[event.buf].buftype == "" then
      vim.b[event.buf].saved_view = vim.fn.winsaveview()
    end
  end,
})

-- Restore view when entering a buffer
autocmd("BufEnter", {
  group = augroup "RestoreView",
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if vim.b[buf].saved_view then
      vim.fn.winrestview(vim.b[buf].saved_view)
    end
  end,
})

-- Soft-wrap markdown at word boundaries so long lines stay readable
autocmd("FileType", {
  desc = "Wrap markdown at word boundaries",
  group = augroup "MarkdownWrap",
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Go to last loc when opening a buffer for the first time
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
