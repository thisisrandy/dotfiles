return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      sections = {
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          -- This is a substitute for the default "location" that includes the
          -- total line number
          -- TODO: If #1334 is accepted, I can enable this with
          -- line_total_in_location = true in opts
          {
            function()
              local line = vim.fn.line(".")
              local col = vim.fn.charcol(".")
              local line_total = vim.fn.line("$")
              return string.format("%3d/%d:%-2d", line, line_total, col)
            end,
            separator = " ",
            padding = { left = 0, right = 1 },
          },
        },
      },
    })
  end,
}
