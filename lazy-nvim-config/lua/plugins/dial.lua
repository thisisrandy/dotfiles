return {
  {
    "monaqa/dial.nvim",
    -- This is mostly the default implementation, but expanded in terms of
    -- which augends are allowed for any given filetype
    opts = function()
      local augend = require("dial.augend")

      local logical_alias = augend.constant.new({
        elements = { "&&", "||" },
        word = false,
        cyclic = true,
      })

      local ordinal_numbers = augend.constant.new({
        -- elements through which we cycle. When we increment, we go down
        -- On decrement we go up
        elements = {
          "first",
          "second",
          "third",
          "fourth",
          "fifth",
          "sixth",
          "seventh",
          "eighth",
          "ninth",
          "tenth",
        },
        -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
        word = false,
        -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
        -- Otherwise nothing will happen when there are no further values
        cyclic = true,
      })

      local weekdays = augend.constant.new({
        elements = {
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        },
        word = true,
        cyclic = true,
      })

      local months = augend.constant.new({
        elements = {
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        },
        word = true,
        cyclic = true,
      })

      local capitalized_boolean = augend.constant.new({
        elements = {
          "True",
          "False",
        },
        word = true,
        cyclic = true,
      })

      local base_group = {
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%H:%M:%S"],
        ordinal_numbers,
        weekdays,
        months,
      }

      local merge_with_base = function(to_merge)
        for k, v in pairs(base_group) do
          to_merge[k] = v
        end
        return to_merge
      end

      return {
        dials_by_ft = {
          css = "css",
          javascript = "typescript",
          javascriptreact = "typescript",
          json = "json",
          lua = "lua",
          markdown = "markdown",
          python = "python",
          sass = "css",
          scss = "css",
          typescript = "typescript",
          typescriptreact = "typescript",
          yaml = "yaml",
        },
        groups = {
          default = base_group,
          typescript = merge_with_base({
            augend.constant.alias.bool,
            logical_alias,
            augend.constant.new({ elements = { "let", "const" } }),
          }),
          yaml = merge_with_base({ augend.constant.alias.bool }),
          css = {
            augend.integer.alias.decimal_int,
            augend.hexcolor.new({
              case = "lower",
            }),
            augend.hexcolor.new({
              case = "upper",
            }),
          },
          markdown = merge_with_base({ augend.misc.alias.markdown_header }),
          json = merge_with_base({ augend.semver.alias.semver }),
          lua = merge_with_base({
            augend.constant.alias.bool, -- boolean value (true <-> false)
            augend.constant.new({
              elements = { "and", "or" },
              word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
              cyclic = true, -- "or" is incremented into "and".
            }),
          }),
          python = merge_with_base({
            capitalized_boolean,
            logical_alias,
          }),
        },
      }
    end,
  },
}
