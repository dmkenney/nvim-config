-- nvim-treesitter `main` branch (the `master` branch is archived and breaks on Neovim 0.12).
-- `main` only installs parsers and queries. Highlighting, indent, and selection are wired
-- up here with Neovim's built-in treesitter. Needs the `tree-sitter` CLI and a C compiler.
local ensure_installed = {
  "elixir",
  "eex",
  "heex",
  "javascript",
  "typescript",
  "bash",
  "c",
  "cpp",
  "go",
  "rust",
  "zig",
  "diff",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

-- Languages that keep Vim regex highlighting alongside treesitter, and skip treesitter indent
local regex_languages = { ruby = true }

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(lang) then
    return
  end
  vim.treesitter.start(buf, lang)

  if regex_languages[lang] then
    vim.bo[buf].syntax = "on"
  else
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end

  -- Incremental selection via Neovim's built-in `an` / `in` (see :help v_an)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, remap = true, desc = desc })
  end
  map("n", "<CR>", "van", "Treesitter: select node")
  map("x", "<CR>", "an", "Treesitter: expand selection")
  map("x", "<TAB>", "an", "Treesitter: expand selection")
  map("x", "<S-TAB>", "in", "Treesitter: shrink selection")
end

return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require "nvim-treesitter"
      ts.install(ensure_installed)

      local available = {}
      for _, lang in ipairs(ts.get_available()) do
        available[lang] = true
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            attach(args.buf, lang)
          elseif available[lang] then
            -- Install missing parsers on first use, then attach
            ts.install(lang):await(function()
              vim.schedule(function()
                attach(args.buf, lang)
              end)
            end)
          end
        end,
      })
    end,
  },
}
