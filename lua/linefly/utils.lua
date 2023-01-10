local M = {}

-- Return the number of split windows exluding floating windows and other
-- special windows.
M.window_count = function()
  local count = 0
  local windows = vim.api.nvim_tabpage_list_wins(0)

  for _, v in pairs(windows) do
    local cfg = vim.api.nvim_win_get_config(v)
    local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(v), "filetype")

    if (cfg.relative == "" or cfg.external == false) and ft ~= "qf" then
      count = count + 1
    end
  end

  return count
end

return M
