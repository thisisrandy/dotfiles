-- Put plugins that need no further configuration here. Otherwise, create a
-- per-plugin or per-plugin group file and store configuration there
return {
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
  },
  { "fladson/vim-kitty" },
  { "andymass/vim-matchup" },
  { -- NOTE: This is on gitlab, not github
    "HiPhish/rainbow-delimiters.nvim",
    config = function(_, opts)
      require("rainbow-delimiters.setup").setup(opts)
      -- With rainbow delimiters on, a fg color change often isn't easily
      -- distinguishable, so we need a stronger visual cue. This is the same
      -- background color used in tokyonight to highlight to object under the
      -- cursor and other instances of it.
      vim.cmd([[highlight MatchParen guibg=#3b4261]])
    end,
  },
}
