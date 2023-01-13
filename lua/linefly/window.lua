local buf_get_option = vim.api.nvim_buf_get_option
local g = vim.g
local setwinvar = vim.fn.setwinvar
local tabpage_list_wins = vim.api.nvim_tabpage_list_wins
local win_get_buf = vim.api.nvim_win_get_buf
local win_get_config = vim.api.nvim_win_get_config
local winheight = vim.api.nvim_win_get_height
local winnr = vim.fn.winnr

local M = {}

-- Return the number of split windows exluding floating windows and other
-- special windows.
M.count = function()
  local count = 0
  local windows = tabpage_list_wins(0)

  for _, w in pairs(windows) do
    local cfg = win_get_config(w)
    local ft = buf_get_option(win_get_buf(w), "filetype")
    local bt = buf_get_option(win_get_buf(w), "buftype")

    if (cfg.relative == "" or cfg.external == false) and ft ~= "qf" and bt ~= "terminal" then
      count = count + 1
    end
  end

  return count
end

-- Iterate though the windows and update the statusline and winbar for all
-- inactive windows.
--
-- This is needed when starting Neovim with multiple splits, for example 'nvim
-- -O file1 file2', otherwise all statuslines/winbars will be rendered as if
-- they are active. Inactive statuslines/winbar are usually rendered via the
-- WinLeave and BufLeave events, but those events are not triggered when
-- starting Vim.
--
-- Note - https://jip.dev/posts/a-simpler-vim-statusline/#inactive-statuslines
M.update_inactive = function()
  for winnum = 1, winnr("$") do
    if winnum ~= winnr() then
      setwinvar(winnum, "&statusline", "%{%v:lua.linefly.inactive_statusline()%}")
      if g.lineflyWinBar and winheight(0) > 1 then
        setwinvar(winnum, "&winbar", "%{%v:lua.linefly.inactive_winbar()%})")
      end
    end
  end
end

return M
