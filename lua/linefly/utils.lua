local buf_get_name = vim.api.nvim_buf_get_name
local buf_get_option = vim.api.nvim_buf_get_option
local expand = vim.fn.expand
local fnamemodify = vim.fn.fnamemodify
local g = vim.g
local has = vim.fn.has
local opt = vim.opt
local pathshorten = vim.fn.pathshorten
local split = vim.split
local tabpage_list_wins = vim.api.nvim_tabpage_list_wins
local win_get_buf = vim.api.nvim_win_get_buf
local win_get_config = vim.api.nvim_win_get_config

local M = {}

local file_icon = function()
  if not g.lineflyWithFileIcon or M.is_empty(buf_get_name(0)) or not g.nvim_web_devicons then
    return ""
  end

  return require("nvim-web-devicons").get_icon(expand("%"), nil, { default = true }) .. " "
end

local file_path = function()
  if buf_get_option(0, "buftype") == "terminal" then
    return expand("%:t")
  else
    if M.is_empty(expand("%:f")) then
      return ""
    end

    local separator = "/"
    if has("win64") == 1 then
      separator = "\\"
    end

    local path
    if opt.laststatus:get() == 3 then
      -- Global statusline is active, no path shortening.
      path = fnamemodify(expand("%:f"), ":~:.")
    else
      path = pathshorten(fnamemodify(expand("%:f"), ":~:."))
    end

    local path_components = split(path, separator)
    local num_path_components = #path_components
    if num_path_components > 4 then
      -- In future, if Neovim switches to Lua 5.2 or above, 'unpack' will need
      -- to change to 'table.unpack'.
      return ".../" .. table.concat({ unpack(path_components, num_path_components - 3) }, separator)
    else
      return path
    end
  end
end

M.is_empty = function(str)
  return str == nil or string.len(str) == 0
end

M.filename = function()
  return file_icon() .. file_path()
end

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
