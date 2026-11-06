-- zsh lazy-loads nvm, so node/npm aren't on PATH unless a shell has already
-- triggered the loader. Mason shells out to npm, so resolve nvm's default node
-- ourselves and put its bin directory on nvim's PATH.
local function nvm_default_bin()
  local nvm_dir = vim.env.NVM_DIR or (vim.env.HOME .. "/.nvm")

  local installed = {}
  for _, dir in ipairs(vim.fn.glob(nvm_dir .. "/versions/node/v*", false, true)) do
    local v = vim.version.parse(vim.fn.fnamemodify(dir, ":t"))
    if v then
      table.insert(installed, { version = v, dir = dir })
    end
  end
  if #installed == 0 then
    return nil
  end
  table.sort(installed, function(a, b)
    return vim.version.lt(b.version, a.version) -- newest first
  end)

  -- Follow alias files (e.g. default -> lts/iron -> v20) until we reach
  -- something that isn't an alias.
  local spec = "default"
  for _ = 1, 5 do
    local f = io.open(nvm_dir .. "/alias/" .. spec)
    if not f then
      break
    end
    spec = vim.trim(f:read("*a"))
    f:close()
  end

  -- "node"/"stable"/unresolved aliases mean the newest install. Otherwise
  -- spec is a full or partial version ("24", "v24.18", "v24.18.0").
  local prefix = spec:match("^v?(%d[%d%.]*)$")
  if prefix then
    for _, item in ipairs(installed) do
      local name = tostring(item.version) .. "."
      if vim.startswith(name, prefix .. ".") then
        return item.dir .. "/bin"
      end
    end
  end
  return installed[1].dir .. "/bin"
end

return {
  "mason-org/mason.nvim",
  init = function()
    local bin = nvm_default_bin()
    if bin and not vim.env.PATH:find(bin, 1, true) then
      vim.env.PATH = bin .. ":" .. vim.env.PATH
    end
  end,
}
