-- Colors follow the Omarchy theme, including live switches (`omarchy theme set`).
--
-- Omarchy writes each theme's spec to ~/.local/state/omarchy/current/theme/neovim.lua
-- in LazyVim form: the colorscheme plugin plus { "LazyVim/LazyVim", opts = { colorscheme } }.
-- This config is not LazyVim (importing that spec would install LazyVim), so the file
-- is read here instead. Without Omarchy (i3 machines) colors fall back to tokyonight-night.

local state_dir = vim.fn.expand "~/.local/state/omarchy/current"
local theme_file = state_dir .. "/theme/neovim.lua"
local fallback = { plugins = {}, colorscheme = "tokyonight-night" }

local function read_theme()
  if not vim.uv.fs_stat(theme_file) then return fallback end
  local ok, spec = pcall(dofile, theme_file)
  if not ok or type(spec) ~= "table" then return fallback end

  local theme = { plugins = {} }
  for _, s in ipairs(spec) do
    if s[1] == "LazyVim/LazyVim" then
      theme.colorscheme = s.opts and s.opts.colorscheme
    else
      table.insert(theme.plugins, s)
    end
  end
  return theme.colorscheme and theme or fallback
end

local function plugin_name(spec)
  return spec.name or spec[1]:match "[^/]+$"
end

-- Switch a running nvim to a theme. Generated Omarchy themes share aether.nvim and differ
-- only in its setup() colors, so unload the plugin's modules and rerun setup with the new opts.
local function apply(theme)
  local Config = require "lazy.core.config"
  local Loader = require "lazy.core.loader"
  for _, spec in ipairs(theme.plugins) do
    local plugin = Config.plugins[plugin_name(spec)]
    if plugin then
      if plugin._.loaded and spec.opts then
        require("lazy.core.util").walkmods(plugin.dir .. "/lua", function(modname)
          package.loaded[modname] = nil
        end)
      end
      Loader.load(plugin, { colorscheme = theme.colorscheme })
      local main = spec.opts and Loader.get_main(plugin)
      if main then pcall(function() require(main).setup(spec.opts) end) end
    end
  end

  vim.cmd "highlight clear"
  vim.o.background = "dark" -- light themes set it back to light
  pcall(vim.cmd.colorscheme, theme.colorscheme)
end

-- theme-set replaces current/theme, then writes current/theme.name last.
local function watch()
  if not vim.uv.fs_stat(state_dir) then return end
  local handle = vim.uv.new_fs_event()
  if not handle then return end
  local pending = false
  handle:start(state_dir, {}, function(err, filename)
    if err or filename ~= "theme.name" or pending then return end
    pending = true
    vim.defer_fn(function()
      pending = false
      apply(read_theme())
    end, 200)
  end)
end

local theme = read_theme()

-- Every Omarchy theme's colorscheme plugin, installed but not loaded, so a live switch
-- never has to download one. Mirrors omarchy-nvim's all-themes.lua; aether's name and
-- branch must match Omarchy's generated spec (default/themed/neovim.lua.tpl).
local specs = {
  { "bjarneo/aether.nvim", branch = "v3", name = "aether", lazy = true, priority = 1000 },
  { "ribru17/bamboo.nvim", lazy = true, priority = 1000 },
  { "bjarneo/ethereal.nvim", lazy = true, priority = 1000 },
  { "bjarneo/hackerman.nvim", lazy = true, priority = 1000 },
  { "bjarneo/vantablack.nvim", lazy = true, priority = 1000 },
  { "bjarneo/white.nvim", lazy = true, priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 1000 },
  { "neanias/everforest-nvim", lazy = true, priority = 1000 },
  { "kepano/flexoki-neovim", lazy = true, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = true, priority = 1000 },
  { "tahayvr/matteblack.nvim", lazy = true, priority = 1000 },
  { "gthelding/monokai-pro.nvim", lazy = true, priority = 1000 },
  { "EdenEast/nightfox.nvim", lazy = true, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 1000 },
  { "ficcdaf/ashen.nvim", lazy = true, priority = 1000 },
  { "folke/tokyonight.nvim", lazy = true, priority = 1000 },
  { "OldJobobo/miasma.nvim", lazy = true, priority = 1000 },
  { "OldJobobo/retro-82.nvim", lazy = true, priority = 1000 },
  { "omacom-io/lumon.nvim", lazy = true, priority = 1000 },
}

-- The current theme's own spec (with its opts) is merged over the list above.
for _, spec in ipairs(theme.plugins) do
  table.insert(specs, spec)
end

table.insert(specs, {
  name = "omarchy-theme",
  dir = vim.fn.stdpath "config",
  lazy = false,
  priority = 900, -- after the colorscheme plugins (1000)
  config = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function() vim.cmd.hi "Comment gui=none" end,
    })
    apply(theme)
    watch()
  end,
})

return specs
