-- Formatting with prettierd (a node daemon, so saving doesn't block the editor)
-- for the filetypes the LazyVim formatting.prettier extra used to cover.
-- Markdown goes only through markdownlint-cli2: lang.markdown puts prettier
-- first, and conform uses it as soon as a prettier binary exists.
local prettierd_fts = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(prettierd_fts) do
        opts.formatters_by_ft[ft] = { "prettierd" }
      end
      for _, ft in ipairs({ "markdown", "markdown.mdx" }) do
        opts.formatters_by_ft[ft] = { "markdownlint-cli2", "markdown-toc" }
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettierd" } },
  },
}
