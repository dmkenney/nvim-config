return {
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview Current File History" },
    },
    config = {
      keymaps = {
        view = {
          ["<Esc>"] = "<cmd>DiffviewClose<cr>",
        },
        file_panel = {
          ["<Esc>"] = "<cmd>DiffviewClose<cr>",
        },
        file_history_panel = {
          ["<Esc>"] = "<cmd>DiffviewClose<cr>",
        },
      },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit" },
      { "<leader>gg", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Log" },
    },
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end, { desc = "Jump to next Git change" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end, { desc = "Jump to previous Git change" })

        -- Actions
        -- visual mode
        map("v", "<leader>gs", function()
          gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "stage Git hunk" })
        map("v", "<leader>gr", function()
          gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "reset Git hunk" })
        -- normal mode
        map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
        map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
        map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Git Stage buffer" })
        map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Git undo stage hunk" })
        map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Git Reset buffer" })
        map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git preview hunk" })
        map("n", "<leader>gb", gitsigns.blame_line, { desc = "Git blame line" })
        map("n", "<leader>gd", gitsigns.diffthis, { desc = "Git diff against index" })
        map("n", "<leader>gD", function()
          gitsigns.diffthis "@"
        end, { desc = "Git Diff against last commit" })
        -- Toggles
        map("n", "<leader>gtD", gitsigns.toggle_deleted, { desc = "Toggle Git show Deleted" })
        map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, { desc = "Toggle Git show blame line" })
      end,
    },
  },
}
