local buf_get_option = vim.api.nvim_buf_get_option
local tabpage_list_wins = vim.api.nvim_tabpage_list_wins
local win_get_buf = vim.api.nvim_win_get_buf
local win_get_config = vim.api.nvim_win_get_config

local M = {}

-- Return the number of split windows exluding floating windows and other
-- special windows.
M.window_count = function()
  local count = 0
  local windows = tabpage_list_wins(0)

  for _, w in pairs(windows) do
    local cfg = win_get_config(w)
    local ft = buf_get_option(win_get_buf(w), "filetype")

    if (cfg.relative == "" or cfg.external == false) and ft ~= "qf" then
      count = count + 1
    end
  end

  return count
end

return M
