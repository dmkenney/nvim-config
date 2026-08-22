-- Markdown previewer with inline rendering + side-by-side split preview
return {
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        -- Don't render in insert mode so raw editing stays clean
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
      },
    },
    keys = {
      { "<leader>mp", "<cmd>Markview Toggle<cr>", desc = "[M]arkview toggle [p]review", ft = "markdown" },
      { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "[M]arkview [s]plit (side-by-side)", ft = "markdown" },
    },
  },
}
