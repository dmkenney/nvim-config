-- Inside flockr (and not in a nested tmux), move between nvim windows and,
-- at nvim's edge, hand off to flockr's pane focus. Needs this in
-- ~/.config/flockr/config.toml so flockr lets ctrl+h/j/k/l through to nvim:
--   [ui]
--   pane_focus_passthrough = ["nvim", "vim"]
local function in_flockr()
  return vim.env.FLOCKR_PANE_ID ~= nil and vim.env.TMUX == nil
end

local directions = { h = "left", j = "down", k = "up", l = "right" }

local function navigate(key, tmux_cmd)
  return function()
    if not in_flockr() then
      vim.cmd(tmux_cmd)
      return
    end
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. key)
    if vim.api.nvim_get_current_win() == win then
      vim.fn.jobstart({
        vim.env.FLOCKR_BIN_PATH or "flockr", "pane", "focus",
        "--pane", vim.env.FLOCKR_PANE_ID,
        "--direction", directions[key],
      }, { detach = true })
    end
  end
end

return {
  "christoomey/vim-tmux-navigator",
  -- The plugin's own ctrl+h/j/k/l mappings would replace the ones below.
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", navigate("h", "TmuxNavigateLeft") },
    { "<c-j>", navigate("j", "TmuxNavigateDown") },
    { "<c-k>", navigate("k", "TmuxNavigateUp") },
    { "<c-l>", navigate("l", "TmuxNavigateRight") },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
