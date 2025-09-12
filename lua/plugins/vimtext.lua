return {
    {
        "lervag/vimtex",
        lazy = false, -- Don't lazy load VimTeX
        ft = "tex", -- Only load for tex files
        init = function()
            -- VimTeX configuration
            vim.g.vimtex_view_method = "zathura" -- Change based on your PDF viewer
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_compiler_latexmk = {
                build_dir = '',
                callback = 1,
                continuous = 1,
                executable = 'latexmk',
                options = {
                    '-verbose',
                    '-file-line-error',
                    '-synctex=1',
                    '-interaction=nonstopmode',
                },
            }
        end,
        keys = {
            { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "LaTeX Compile" },
            { "<leader>lv", "<cmd>VimtexView<cr>", desc = "LaTeX View PDF" },
            { "<leader>li", "<cmd>VimtexInfo<cr>", desc = "LaTeX Info" },
            { "<leader>lc", "<cmd>VimtexClean<cr>", desc = "LaTeX Clean" },
            { "<leader>ls", "<cmd>VimtexStop<cr>", desc = "LaTeX Stop" },
            { "<leader>lt", "<cmd>VimtexTocToggle<cr>", desc = "LaTeX TOC Toggle" },
            { "<leader>le", "<cmd>VimtexErrors<cr>", desc = "LaTeX Errors" },
        },
    }
}
