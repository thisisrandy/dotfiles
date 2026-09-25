return {
  {
    -- NOTE: Mason installs this under the hood
    "zbirenbaum/copilot.lua",
    dependencies = {
      { "copilotlsp-nvim/copilot-lsp" },
    },
    opts = function(_, opts)
      require("copilot").setup({})
      return opts
    end,
  },
}
