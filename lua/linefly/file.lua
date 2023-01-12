local is_empty = require("linefly.utils").is_empty
local buf_get_name = vim.api.nvim_buf_get_name
local buf_get_option = vim.api.nvim_buf_get_option
local expand = vim.fn.expand
local fnamemodify = vim.fn.fnamemodify
local g = vim.g
local pathshorten = vim.fn.pathshorten

local file_icon = function()
  if not g.lineflyWithFileIcon or is_empty(buf_get_name(0)) or not g.nvim_web_devicons then
    return ""
  end

  return require("nvim-web-devicons").get_icon(expand("%"), nil, { default = true }) .. " "
end

local file_path = function()
  if is_empty(expand("%:f")) then
    return ""
  end

  if buf_get_option(0, "buftype") == "terminal" then
    return expand("%:t")
  end

  local separator = "/"
  if vim.fn.has("win64") == 1 then
    separator = "\\"
  end

  local path
  if vim.opt.laststatus:get() == 3 then
    -- Global statusline is active, no path shortening.
    path = fnamemodify(expand("%:f"), ":~:.")
  else
    path = pathshorten(fnamemodify(expand("%:f"), ":~:."))
  end

  local path_components = vim.split(path, separator)
  local num_path_components = #path_components
  if num_path_components > 4 then
    -- In future, if Neovim switches to Lua 5.2 or above, 'unpack' will need
    -- to change to 'table.unpack'.
    return ".../" .. table.concat({ unpack(path_components, num_path_components - 3) }, separator)
  else
    return path
  end
end

local M = {}

M.name = function()
  return file_icon() .. file_path()
end

return M
