return {
  {
    "LintaoAmons/bookmarks.nvim",
    lazy = false, -- LazyVim doesn't load by default. The load impact is minimal
    tag = "v4.0.0", -- Pinning to stable version as recommended by the author
    dependencies = {
      { "kkharji/sqlite.lua" },
      -- picker backend (choose one):
      -- { "folke/snacks.nvim" }, -- default picker backend
      { "nvim-telescope/telescope.nvim" }, -- set picker.picker_backend = "telescope" to use
    },
    init = function()
      require("which-key").add({
        { "<leader>m", group = "Book[m]arks" },
      })
    end,
    keys = {
      -- Core / Frequent Operations
      { "<leader>mm", "<cmd>BookmarksMark<cr>", desc = "Mark/Rename line" },
      { "<leader>mo", "<cmd>BookmarksGoto<cr>", desc = "Go to active list mark" },
      { "<leader>md", "<cmd>BookmarksDesc<cr>", desc = "Add description to mark" },

      -- Treeview
      { "<leader>mt", "<cmd>BookmarksTree<cr>", desc = "Toggle Bookmarks Treeview" },

      -- Quick Navigation
      { "<leader>mj", "<cmd>BookmarksGotoNext<cr>", desc = "Next mark (Line order)" },
      { "<leader>mk", "<cmd>BookmarksGotoPrev<cr>", desc = "Prev mark (Line order)" },
      { "<leader>mJ", "<cmd>BookmarksGotoNextInList<cr>", desc = "Next mark (ID order)" },
      { "<leader>mK", "<cmd>BookmarksGotoPrevInList<cr>", desc = "Prev mark (ID order)" },

      -- Lists and Commands Pickers
      { "<leader>ml", "<cmd>BookmarksLists<cr>", desc = "Pick a bookmark list" },
      { "<leader>mc", "<cmd>BookmarksCommands<cr>", desc = "Find bookmark commands" },
      { "<leader>mn", "<cmd>BookmarksNewList<cr>", desc = "Create a new list" },

      -- Search and Utilities
      { "<leader>mg", "<cmd>BookmarksGrep<cr>", desc = "Grep through bookmarked files" },
      { "<leader>mi", "<cmd>BookmarksInfo<cr>", desc = "Show plugin status info" },
      { "<leader>mh", "<cmd>BookmarksInfoCurrentBookmark<cr>", desc = "Show current mark info" },
      { "<leader>mr", "<cmd>BookmarkRebindOrphanNode<cr>", desc = "Rebind orphaned nodes" },
    },
    config = function()
      local opts = {
        signs = {
          mark = {
            line_bg = "#5f0dbd",
            color = "#b176f5",
          },
        },
        treeview = { window_split_dimension = 40 },
        picker = { picker_backend = "telescope" },
      }
      require("bookmarks").setup(opts)

      -- project.nvim integration. See
      -- https://github.com/LintaoAmons/bookmarks.nvim/blob/main/ADVANCED_USAGE.md
      local find_or_create_project_bookmark_group = function()
        local project_root = require("project_nvim.project").get_project_root()
        if not project_root then
          return
        end

        local project_name = string.gsub(project_root, "^" .. os.getenv("HOME") .. "/", "")
        local Service = require("bookmarks.domain.service")
        local Repo = require("bookmarks.domain.repo")
        local bookmark_list = nil

        for _, bl in ipairs(Repo.find_lists()) do
          if bl.name == project_name then
            bookmark_list = bl
            break
          end
        end

        if not bookmark_list then
          bookmark_list = Service.create_list(project_name)
        end
        Service.set_active_list(bookmark_list.id)
        require("bookmarks.sign").safe_refresh_signs()
      end
      vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("BookmarksGroup", {}),
        pattern = { "*" },
        callback = find_or_create_project_bookmark_group,
      })
    end,
  },
}
