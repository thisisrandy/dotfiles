return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "html",
        "javascript",
        "json",
        "latex",
        "lua",
        "markdown",
        "markdown_inline",
        -- These are provided by nvim-neorg/tree-sitter-norg and
        -- nvim-neorg/tree-sitter-norg-meta. In 306e1034, I said I was adding
        -- norg because it's required by Snacks.image, so maybe I was following
        -- some instructions that have since updated
        -- "norg",
        -- "norg_meta",
        "python",
        "query",
        "regex",
        "scss",
        "svelte",
        "tsx",
        "typescript",
        "typst",
        "vim",
        "vue",
        "yaml",
      },
      matchup = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 10, -- override 3 from LazyVim config
    },
  },
}
