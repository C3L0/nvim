return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/nvim-cmp',         -- optional if you want completion
        'hrsh7th/cmp-nvim-lsp',     -- completion source
    },
    config = function()
        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = { "pyright" },
        })

        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        lspconfig.pyright.setup({
            capabilities = capabilities,
        })
    end
}

