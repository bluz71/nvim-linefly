local options = require("linefly.options").list
local utils = require("linefly.utils")
local buf_get_option = vim.api.nvim_buf_get_option
local get_option = vim.api.nvim_get_option
local tabpage_list_wins = vim.api.nvim_tabpage_list_wins
local win_get_buf = vim.api.nvim_win_get_buf
local win_get_config = vim.api.nvim_win_get_config
local win_get_height = vim.api.nvim_win_get_height
local win_get_number = vim.api.nvim_win_get_number
local win_get_width = vim.api.nvim_win_get_width
local win_set_option = vim.api.nvim_win_set_option

local M = {}

-- Return the number of split windows exluding floating windows and other
-- special windows.
M.count = function()
  local count = 0
  local windows = tabpage_list_wins(0)

  for _, w in pairs(windows) do
    local cfg = win_get_config(w)
    local buf = win_get_buf(w)
    local bt = buf_get_option(buf, "buftype")
    local ft = buf_get_option(buf, "filetype")

    if utils.is_empty(cfg.relative) and bt ~= "nofile" and ft ~= "netrw" and ft ~= "oil" then
      count = count + 1
    end
  end

  return count
end

M.is_floating = function()
  if utils.is_present(win_get_config(0).relative) then
    return true
  else
    return false
  end
end

-- Iterate over the active windows and update the statusline and winbar for all
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
  local windows = tabpage_list_wins(0)
  local current_window = win_get_number(0)

  for _, w in pairs(windows) do
    if win_get_number(w) ~= current_window then
      win_set_option(w, "statusline", "%{%v:lua.linefly.inactive_statusline()%}")
      if options().winbar and win_get_height(0) > 1 then
        win_set_option(w, "winbar", "%{%v:lua.linefly.inactive_winbar()%}")
      end
    end
  end
end

-- Iterate over the active windows looking for the quickfix list, when found
-- deactive its winbar.
--
-- Note, Neovim DiffTool, which displays the quickfix list, activates through
-- diff option setting, not through traditional Vim entering. Hence, the need
-- for this iterative approach.
--
-- This function will be called via an OptionSet "diff" autocmd.
M.unset_quickfix_winbar = function()
  if not options().winbar then
    -- Exit early, winbar option is not active.
    return
  end

  local windows = tabpage_list_wins(0)

  for _, w in pairs(windows) do
    if buf_get_option(win_get_buf(w), "filetype") == "qf" then
      win_set_option(w, "winbar", nil)
      -- The quickfix list was found, exit immediately.
      return
    end
  end
end

-- The Neovim Undotree plugin window launches by splitting the current buffer
-- into a new vertical split then overwriting that new split with the Undotree
-- contents. This breaks linefly winbar handling by first expanding the window
-- count (usually 1 to 2) but then when the Undotree contents populate the split
-- the window count changes (usually 2 back to 1, see count() above) because
-- 'nofile' buffer types are ignored (Undotree sets it buffer type to 'nofile').
-- However, at that point it is too late, the solo buffer window (not the
-- Undotree split) will have an extraneous winbar. We only want winbars when
-- there are 2 or more real windows (sans 'nofile' and quickfix lists etc).
--
-- The only solution I can figure out is to blank out winbars when a FileType
-- "nvim-undotree" event is encountered and the window count is only 1.
M.unset_winbars = function()
  if not options().winbar then
    -- Exit early, winbar option is not active.
    return
  end

  if M.count() == 1 then
    -- The real window count is only 1, that is sans 'nofile' and quickfix lists
    -- etc. Blank out all winbars in that case.
    local windows = tabpage_list_wins(0)

    for _, w in pairs(windows) do
      win_set_option(w, "winbar", nil)
    end
  end
end

M.statusline_width = function()
  if vim.o.laststatus == 3 then
    return get_option("columns")
  else
    return win_get_width(0)
  end
end

return M
