local g = vim.g
local options_initialized = false

local M = {}

M.list = function()
  if not options_initialized or not g.linefly_options then
    g.linefly_options = g.linefly_options or {}
    local default_options = {
      separator_symbol = "⎪",
      progress_symbol = "↓",
      active_tab_symbol = "▪",
      git_branch_symbol = "",
      error_symbol = "E",
      warning_symbol = "W",
      information_symbol = "I",
      ellipsis_symbol = "…",
      tabline = false,
      winbar = false,
      with_file_icon = true,
      with_git_branch = true,
      with_git_status = true,
      with_diagnostic_status = true,
      with_session_status = true,
      with_lsp_names = true,
      with_macro_status = false,
      with_search_count = false,
      with_spell_status = false,
      with_indent_status = false,
    }
    g.linefly_options = vim.tbl_extend("force", default_options, g.linefly_options)
    options_initialized = true
  end

  return g.linefly_options
end

return M
