return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "css",
        "latex",
        -- These are provided by nvim-neorg/tree-sitter-norg and
        -- nvim-neorg/tree-sitter-norg-meta. In 306e1034, I said I was adding
        -- norg because it's required by Snacks.image, so maybe I was following
        -- some instructions that have since updated
        -- "norg",
        -- "norg_meta",
        "scss",
        "svelte",
        "typst",
        "vue",
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
