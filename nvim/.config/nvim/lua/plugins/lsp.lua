-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        "mason-org/mason.nvim",
        opts = {},
      },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      -- This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Rename the variable under your cursor.
          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action
          map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

          -- Find references for the word under your cursor.
          map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the definition of the word under your cursor.
          map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Goto Declaration.
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Fuzzy find all the symbols in your current document.
          map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

          -- Fuzzy find all the symbols in your current workspace.
          map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

          -- Jump to the type of the word under your cursor.
          map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            return client:supports_method(method, bufnr)
          end

          -- Highlight references of the word under cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
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
                vim.api.nvim_clear_autocmds {
                  group = "kickstart-lsp-highlight",
                  buffer = event2.buf,
                }
              end,
            })
          end

          -- Toggle inlay hints
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map(
              "<leader>th",
              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
              "[T]oggle Inlay [H]ints"
            )
          end
        end,
      })

      -- Diagnostic Config
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- Get capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local tools = require "config.tools"

      -- Collect tools needed for mason-tool-installer
      local tools_needed = {}
      for _, formatters in pairs(tools.formatters) do
        vim.list_extend(tools_needed, formatters)
      end

      for _, linters in pairs(tools.linters) do
        vim.list_extend(tools_needed, linters)
      end

      local ensure_installed = vim.tbl_keys(tools.servers or {})
      vim.list_extend(ensure_installed, tools_needed)
      vim.list_extend(ensure_installed, tools.additional_tools)

      -- Filter out servers that have different Mason package names
      ensure_installed = vim.tbl_filter(function(name)
        return name ~= "volar"
      end, ensure_installed)

      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      require("mason-lspconfig").setup {
        ensure_installed = {},
        automatic_enable = false,
        automatic_installation = false,
      }

      -- Configure and enable LSP servers using vim.lsp.config
      for server, config in pairs(tools.servers) do
        -- Merge capabilities
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})

        -- Configure the server
        vim.lsp.config[server] = config
      end

      -- Enable all configured servers
      vim.lsp.enable(vim.tbl_keys(tools.servers))
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
  },
}
