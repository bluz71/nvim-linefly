local options_list = {
  separator_symbol = "⎪",
  arrow_symbol = "↓",
  active_tab_symbol = "▪",
  git_branch_symbol = "",
  error_symbol = "E",
  warning_symbol = "W",
  information_symbol = "I",
  tabline = false,
  winbar = false,
  with_diagnostic_status = true,
  with_indent_status = false,
  with_file_icon = true,
  with_git_branch = true,
  with_gitsigns_status = true,
}

local user_settings_merged = false

local M = {}

M.list = function()
  if not user_settings_merged then
    options_list = vim.tbl_extend("force", options_list, vim.g.linefly_options or {})
    user_settings_merged = true
  end

  return options_list
end

return M
