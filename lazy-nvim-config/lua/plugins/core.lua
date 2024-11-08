-- Put plugins that need no further configuration here. Otherwise, create a
-- per-plugin or per-plugin group file and store configuration there
return {
  {
    "junegunn/fzf",
    build = function()
      vim.fn["fzf#install"]()
    end,
  },
  { "fladson/vim-kitty" },
  { "andymass/vim-matchup" },
}
