local g = vim.g

local options_list = {
  ascii_shapes = false,
  error_symbol = "E",
  warning_symbol = "W",
  information_symbol = "I",
  tabline = false,
  winbar = false,
  with_diagnostic_status = true,
  with_file_icon = false,
  with_git_branch = true,
  with_gitsigns_status = true,
  with_indent_status = false,
}

local user_settings_merged = false

local M = {}

M.list = function()
  if not user_settings_merged then
    options_list = vim.tbl_extend("force", options_list, g.linefly_options or {})
    user_settings_merged = true
  end

  return options_list
end

return M