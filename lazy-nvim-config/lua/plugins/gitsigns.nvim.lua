return {
  "lewis6991/gitsigns.nvim",

  -- NOTE: This logic completely replaces braxtons12/blame_line.nvim, which
  -- conflicts with noice's hover text (it flashes at the top of the screen
  -- just before disappearing)

  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 0,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },

    current_line_blame_formatter = function(name, blame_info)
      local now = os.time()
      local commit_time = blame_info.author_time
      local diff = now - commit_time

      local time_string = ""
      if diff < 60 then
        time_string = "just now"
      elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        time_string = mins == 1 and "1 minute ago" or mins .. " minutes ago"
      elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        time_string = hours == 1 and "1 hour ago" or hours .. " hours ago"
      elseif diff < 2592000 then
        local days = math.floor(diff / 86400)
        time_string = days == 1 and "yesterday" or days .. " days ago"
      elseif diff < 31536000 then
        local months = math.floor(diff / 2592000)
        time_string = months == 1 and "last month" or months .. " months ago"
      else
        local years = math.floor(diff / 31536000)
        time_string = years == 1 and "last year" or years .. " years ago"
      end

      local message = string.format("    %s • %s • %s", name, time_string, blame_info.summary)

      return { { message, "GitSignsCurrentLineBlame" } }
    end,
  },
}
