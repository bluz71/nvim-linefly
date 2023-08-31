local g = vim.g
local options_initialized = false

local M = {}

M.list = function()
  if not options_initialized or not g.linefly_options then
    g.linefly_options = g.linefly_options or {}
    g.linefly_options = {
      separator_symbol = g.linefly_options.separator_symbol or "⎪",
      progress_symbol = g.linefly_options.progress_symbol or "↓",
      active_tab_symbol = g.linefly_options.active_tab_symbol or "▪",
      git_branch_symbol = g.linefly_options.git_branch_symbol or "",
      error_symbol = g.linefly_options.error_symbol or "E",
      warning_symbol = g.linefly_options.warning_symbol or "W",
      information_symbol = g.linefly_options.information_symbol or "I",
      ellipsis_symbol = g.linefly_options.ellipsis_symbol or "…",
      tabline = g.linefly_options.tabline or false,
      winbar = g.linefly_options.winbar or false,
      with_file_icon = g.linefly_options.with_file_icon or true,
      with_git_branch = g.linefly_options.with_git_branch or true,
      with_git_status = g.linefly_options.with_git_status or true,
      with_diagnostic_status = g.linefly_options.with_diagnostic_status or true,
      with_session_status = g.linefly_options.with_session_status or true,
      with_lsp_names = g.linefly_options.with_lsp_names or true,
      with_macro_status = g.linefly_options.with_macro_status or false,
      with_search_count = g.linefly_options.with_search_count or false,
      with_spell_status = g.linefly_options.with_spell_status or false,
      with_indent_status = g.linefly_options.with_indent_status or false,
    }
    options_initialized = true
  end

  return g.linefly_options
end

return M
