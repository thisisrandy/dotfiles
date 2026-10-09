return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { mode = "n", "gh", "K", desc = "Hover (synonym for K)", remap = true },
      { mode = "n", "<F2>", "<leader>cr", desc = "Rename", remap = true },
    },
    opts = function(_, opts)
      -- Only on machines that have an ARM toolchain in one of these places: lets
      -- clangd ask arm-none-eabi-g++ for its C++ standard library include paths
      -- (fixes "'new' file not found"). Which one ends up in compile_commands.json
      -- depends on how the project's build dir was configured, so allow both.
      local home = vim.env.HOME
      local candidates = {
        home .. "/.local/share/arm-gnu-toolchain-*/bin/arm-none-eabi-",
        home .. "/.local/share/stm32cube/bundles/gnu-tools-for-stm32/*/bin/arm-none-eabi-",
      }
      local allowed = {}
      for _, prefix in ipairs(candidates) do
        if #vim.fn.glob(prefix .. "g++", false, true) > 0 then
          table.insert(allowed, prefix .. "*")
        end
      end
      local clangd = opts.servers and opts.servers.clangd
      if #allowed > 0 and clangd and clangd.cmd then
        table.insert(clangd.cmd, "--query-driver=" .. table.concat(allowed, ","))
      end
    end,
  },
}
