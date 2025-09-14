return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- LSP
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

        -- Completion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',

        -- Snippets
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',

        -- Formatter / Linter
        'nvimtools/none-ls.nvim', -- null-ls fork
    },
    config = function()
        -------------------------------------------------------
        -- Mason & LSP servers
        -------------------------------------------------------
        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = { "lua_ls", "pyright", "ruff", "texlab", "intelephense", "ts_ls", "eslint" },
        })

        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        lspconfig.pyright.setup({ capabilities = capabilities })
        lspconfig.ruff.setup({ capabilities = capabilities })
        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = { library = { vim.env.VIMRUNTIME } },
                },
            },
        })
        lspconfig.texlab.setup({
            capabilities = capabilities,
            settings = {
                texlab = {
                    auxDirectory = ".",
                    bibtexFormatter = "texlab",
                    build = {
                        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                        executable = "latexmk",
                        forwardSearchAfter = false,
                        onSave = false,
                    },
                    chktex = {
                        onEdit = false,
                        onOpenAndSave = false,
                    },
                    diagnosticsDelay = 300,
                    formatterLineLength = 80,
                    forwardSearch = { args = {} },
                    latexFormatter = "latexindent",
                    latexindent = { modifyLineBreaks = false },
                },
            },
        })

        -------------------------------------------------------
        -- null-ls (Black + isort)
        -------------------------------------------------------
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.isort,
            },
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.py",
            callback = function()
                vim.lsp.buf.format({ async = false })
            end,
        })


        -------------------------------------------------------
        -- UI: Borders & diagnostics
        -------------------------------------------------------
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
            vim.lsp.handlers.hover, { border = 'rounded' }
        )
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
            vim.lsp.handlers.signature_help, { border = 'rounded' }
        )
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = {
                style = 'minimal',
                border = 'rounded',
                header = '',
                prefix = '',
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN]  = '▲',
                    [vim.diagnostic.severity.HINT]  = '⚑',
                    [vim.diagnostic.severity.INFO]  = '»',
                },
            },
        })

        -------------------------------------------------------
        -- Keymaps on LSP attach
        -------------------------------------------------------
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = { buffer = event.buf }
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
                vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)

                if vim.bo[event.buf].filetype == 'tex' then
                    vim.keymap.set('n', '<Leader>K', '<plug>(vimtex-doc-package)', { buffer = event.buf, silent = true })
                end
            end,
        })

        -------------------------------------------------------
        -- nvim-cmp setup
        -------------------------------------------------------
        local cmp = require('cmp')
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            preselect = 'item',
            completion = { completeopt = 'menu,menuone,noinsert' },
            window = { documentation = cmp.config.window.bordered() },
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'buffer',  keyword_length = 3 },
                { name = 'luasnip', keyword_length = 2 },
            },
            snippet = {
                expand = function(args) require('luasnip').lsp_expand(args.body) end,
            },
            formatting = {
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local n = entry.source.name
                    item.menu = (n == 'nvim_lsp') and '[LSP]' or string.format('[%s]', n)
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-f>'] = cmp.mapping.scroll_docs(5),
                ['<C-u>'] = cmp.mapping.scroll_docs(-5),
                ['<C-e>'] = cmp.mapping(function()
                    if cmp.visible() then cmp.abort() else cmp.complete() end
                end),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = 'select' })
                    elseif vim.fn.col('.') == 1 or vim.fn.getline('.'):sub(vim.fn.col('.') - 1, vim.fn.col('.') - 1):match('%s') then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                ['<C-d>'] = cmp.mapping(function(fallback)
                    local ls = require('luasnip')
                    if ls.jumpable(1) then ls.jump(1) else fallback() end
                end, { 'i', 's' }),
                ['<C-b>'] = cmp.mapping(function(fallback)
                    local ls = require('luasnip')
                    if ls.jumpable(-1) then ls.jump(-1) else fallback() end
                end, { 'i', 's' }),
            }),
        })
    end
}

-- return {
--     'neovim/nvim-lspconfig',
--     dependencies = {
--         'williamboman/mason.nvim',
--         'williamboman/mason-lspconfig.nvim',
--         'hrsh7th/nvim-cmp',
--         'hrsh7th/cmp-nvim-lsp',
--         'nvimtools/none-ls.nvim', -- null-ls fork
--     },
--     config = function()
--         require('mason').setup()
--         require('mason-lspconfig').setup({
--             ensure_installed = {"pyright", "ruff", "texlab"},
--         })
--         local lspconfig = require('lspconfig')
--         local capabilities = require('cmp_nvim_lsp').default_capabilities()
--         
--         -- LSP servers
--         lspconfig.pyright.setup({ capabilities = capabilities })
--         lspconfig.ruff.setup({ capabilities = capabilities })
--         
--         -- TeXLab LSP for LaTeX
--         lspconfig.texlab.setup({
--             capabilities = capabilities,
--             settings = {
--                 texlab = {
--                     auxDirectory = ".",
--                     bibtexFormatter = "texlab",
--                     build = {
--                         args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
--                         executable = "latexmk",
--                         forwardSearchAfter = false,
--                         onSave = false,
--                     },
--                     chktex = {
--                         onEdit = false,
--                         onOpenAndSave = false,
--                     },
--                     diagnosticsDelay = 300,
--                     formatterLineLength = 80,
--                     forwardSearch = {
--                         args = {}
--                     },
--                     latexFormatter = "latexindent",
--                     latexindent = {
--                         modifyLineBreaks = false,
--                     },
--                 },
--             },
--         })
--         
--         -- Black formatter via none-ls
--         local null_ls = require("null-ls")
--         null_ls.setup({
--             sources = {
--                 null_ls.builtins.formatting.black,
--                 null_ls.builtins.formatting.isort, -- optional
--             },
--         })
--         
--         -- Autoformat Python files with Black
--         vim.api.nvim_create_autocmd("BufWritePre", {
--             pattern = "*.py",
--             callback = function()
--                 vim.lsp.buf.format({ async = false })
-- 	    end,
-- 	})
--         
--         -- Keymaps
--         vim.api.nvim_create_autocmd('LspAttach', {
--             callback = function(event)
--                 local opts = { buffer = event.buf }
--                 vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
--                 vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
--                 vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
--                 vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
--                 vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
--                 vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
--                 vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
--                 vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
--                 
--                 -- LaTeX-specific keymap
--                 if vim.bo[event.buf].filetype == 'tex' then
--                     vim.keymap.set('n', '<Leader>K', '<plug>(vimtex-doc-package)', 
--                         { buffer = event.buf, desc = "Vimtex Docs", silent = true })
--                 end
--             end,
--         })
--     end
-- }
