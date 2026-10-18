return {
  -- LSP Configuration & Plugins
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },

      -- JSON and YAML schemas from schemastore.org for jsonls and yamlls
      "b0o/SchemaStore.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")

          -- Find references for the word under your cursor.
          map("grr", require("telescope.builtin").lsp_references, "Goto References")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          -- map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "Rename")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          -- if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          --   map("<leader>th", function()
          --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          --   end, "Toggle Inlay Hints")
          -- end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  blink.cmp adds more, so we create new capabilities with it and broadcast them to the servers.
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        tailwindcss = {
          init_options = {
            userLanguages = {
              elixir = "html-eex",
              eelixir = "html-eex",
              heex = "html-eex",
            },
          },
        },
        html = {
          filetypes = { "html", "heex" },
          on_attach = function(client, bufnr)
            if vim.bo[bufnr].filetype == "heex" then
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          end,
        },
        expert = {},
        bashls = {},
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              -- Use SchemaStore.nvim's schemas instead of yamlls's built-in store
              schemaStore = { enable = false, url = "" },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },
        clangd = {},
        zls = {},
        rust_analyzer = {},
        gopls = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
        "shellcheck", -- Used by bashls for shell script diagnostics
      })
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      vim.lsp.config("*", { capabilities = capabilities })
      for server_name, server in pairs(servers) do
        vim.lsp.config(server_name, server)
      end

      -- Enables every Mason-installed server with vim.lsp.enable
      require("mason-lspconfig").setup {
        automatic_enable = {
          exclude = { "stylua" }, -- stylua is only used as a formatter through conform
        },
      }
    end,
  },
}
