return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "asm",
        "awk",
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "dockerfile",
        "doxygen",
        "go",
        "haskel",
        "html",
        "java",
        "javascript",
        "json",
        "jq",
        "kitty",
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
        "perl",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "sql",
        "svelte",
        "tsx",
        "typescript",
        "typst",
        "vim",
        "vue",
        "yaml",
        "zsh",
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
