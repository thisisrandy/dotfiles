return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      sections = {
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          -- This is a substitute for the default "location" that includes the
          -- total line number
          {
            function()
              local r, c = unpack(vim.api.nvim_win_get_cursor(0))
              return r .. "/" .. tostring(vim.fn.line("$")) .. ":" .. c
            end,
            separator = " ",
            padding = { left = 0, right = 1 },
          },
        },
      },
    })
  end,
}
