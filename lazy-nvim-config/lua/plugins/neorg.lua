return {
  "nvim-neorg/neorg",
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  config = true,
  -- These are implicit, but setting them explicitly seems to quiet a not found
  -- error that's probably a race condition
  -- NOTE: These won't build without lua 5.1 and luarocks installed against it
  dependencies = {
    "nvim-neorg/tree-sitter-norg",
    "nvim-neorg/tree-sitter-norg-meta",
  },
}
