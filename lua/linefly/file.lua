local is_empty = require("linefly.utils").is_empty
local options = require("linefly.options").list
local buf_get_name = vim.api.nvim_buf_get_name
local buf_get_option = vim.api.nvim_buf_get_option
local expand = vim.fn.expand
local fnamemodify = vim.fn.fnamemodify
local pathshorten = vim.fn.pathshorten

local file_icon = function()
  if not options().with_file_icon or is_empty(buf_get_name(0)) or not vim.g.nvim_web_devicons then
    return ""
  end

  return require("nvim-web-devicons").get_icon(expand("%"), nil, { default = true }) .. " "
end

local file_path = function(short_path)
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
  if short_path then
    path = pathshorten(fnamemodify(expand("%:f"), ":~:."))
  else
    path = fnamemodify(expand("%:f"), ":~:.")
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

M.name = function(short_path)
  return file_icon() .. file_path(short_path)
end

return M
