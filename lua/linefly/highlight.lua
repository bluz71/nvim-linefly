local is_empty = require("linefly.utils").is_empty
local is_present = require("linefly.utils").is_present
local location = require("linefly.constants").location
local options = require("linefly.options").list
local g = vim.g
local get_highlight = vim.api.nvim_get_hl
local highlight = vim.api.nvim_set_hl

-- Cache current statusline backgrounds for performance reasons; that being to
-- avoid needless highlight extraction and generation.
local statusline_bg
local statusline_nc_bg

-- Use a cache to avoid needlessly regenerating a highlight group for the same
-- DevIcon filetype.
local file_icon_highlight_cache = {}

local highlight_empty = function(group)
  return get_highlight(0, { name = group }) == vim.empty_dict()
    or is_empty(get_highlight(0, { name = group, link = false }).bg)
end

local highlight_present = function(group)
  return get_highlight(0, { name = group }) ~= vim.empty_dict()
end

local synthesize_highlight = function(target, source, reverse)
  local source_fg

  if reverse then
    source_fg = get_highlight(0, { name = source, link = false }).bg
  else
    source_fg = get_highlight(0, { name = source, link = false }).fg
  end

  if is_present(statusline_bg) and is_present(source_fg) then
    highlight(0, target, { bg = statusline_bg, fg = source_fg })
  else
    -- Fallback to statusline highlighting.
    highlight(0, target, { link = "StatusLine" })
  end
end

local synthesize_mode_highlight = function(target, background, foreground)
  local mode_bg = get_highlight(0, { name = background, link = false }).fg
  local mode_fg = get_highlight(0, { name = foreground, link = false }).fg

  if is_present(mode_bg) and is_present(mode_fg) then
    highlight(0, target, { bg = mode_bg, fg = mode_fg })
  else
    -- Fallback to statusline highlighting.
    highlight(0, target, { link = "StatusLine" })
  end
end

local colorscheme_diagnostic_highlights = function()
  if highlight_present("DiagnosticError") then
    synthesize_highlight("LineflyDiagnosticError", "DiagnosticError", false)
  else
    highlight(0, "LineflyDiagnosticError", { link = "StatusLine" })
  end
  if highlight_present("DiagnosticWarn") then
    synthesize_highlight("LineflyDiagnosticWarning", "DiagnosticWarn", false)
  else
    highlight(0, "LineflyDiagnosticWarning", { link = "StatusLine" })
  end
  if highlight_present("DiagnosticInfo") then
    synthesize_highlight("LineflyDiagnosticInformation", "DiagnosticInfo", false)
  else
    highlight(0, "LineflyDiagnosticInformation", { link = "StatusLine" })
  end
end

local colorscheme_git_highlights = function()
  if g.colors_name == "default" and highlight_present("Added") then
    synthesize_highlight("LineflyGitAdd", "Added", false)
    synthesize_highlight("LineflyGitChange", "Changed", false)
    synthesize_highlight("LineflyGitDelete", "Removed", false)
  elseif highlight_present("GitSignsAdd") then
    synthesize_highlight("LineflyGitAdd", "GitSignsAdd", false)
    synthesize_highlight("LineflyGitChange", "GitSignsChange", false)
    synthesize_highlight("LineflyGitDelete", "GitSignsDelete", false)
  elseif highlight_present("diffAdded") then
    synthesize_highlight("LineflyGitAdd", "diffAdded", false)
    synthesize_highlight("LineflyGitChange", "diffChanged", false)
    synthesize_highlight("LineflyGitDelete", "diffRemoved", false)
  else
    highlight(0, "LineflyGitAdd", { link = "StatusLine" })
    highlight(0, "LineflyGitChange", { link = "StatusLine" })
    highlight(0, "LineflyGitDelete", { link = "StatusLine" })
  end
end

local colorscheme_mode_highlights = function()
  if g.colors_name == "moonfly" or g.colors_name == "nightfly" then
    -- Do nothing since both colorschemes already set linefly mode colors.
    return
  elseif g.colors_name == "default" then
    synthesize_mode_highlight("LineflyNormal", "Directory", "VertSplit")
    synthesize_mode_highlight("LIneflyInsert", "String", "VertSplit")
    synthesize_mode_highlight("LineflyVisual", "Identifier", "VertSplit")
    synthesize_mode_highlight("LineflyCommand", "WarningMsg", "VertSplit")
    synthesize_mode_highlight("LineflyReplace", "Removed", "VertSplit")
  elseif
    g.colors_name == "bamboo"
    or g.colors_name == "catppuccin-frappe"
    or g.colors_name == "catppuccin-latte"
    or g.colors_name == "catppuccin-macchiato"
    or g.colors_name == "catppuccin-mocha"
    or g.colors_name == "cyberdream"
    or g.colors_name == "dracula"
    or g.colors_name == "dracula-soft"
    or g.colors_name == "edge"
    or g.colors_name == "everforest"
    or g.colors_name == "gruvbox-material"
    or g.colors_name == "kanagawa"
    or g.colors_name == "minicyan"
    or g.colors_name == "minischeme"
    or g.colors_name == "nord"
    or g.colors_name == "nordic"
    or g.colors_name == "onedark"
    or g.colors_name == "rose-pine"
    or g.colors_name == "sonokai"
    or g.colors_name == "tokyonight"
    or g.colors_name == "vscode"
  then
    highlight(0, "LineflyNormal", { link = "MiniStatuslineModeNormal" })
    highlight(0, "LineflyInsert", { link = "MiniStatuslineModeInsert" })
    highlight(0, "LineflyVisual", { link = "MiniStatuslineModeVisual" })
    highlight(0, "LineflyCommand", { link = "MiniStatuslineModeCommand" })
    highlight(0, "LineflyReplace", { link = "MiniStatuslineModeReplace" })
  elseif g.colors_name == "gruvbox" then
    synthesize_mode_highlight("LineflyNormal", "GruvboxFg4", "GruvboxBg0")
    synthesize_mode_highlight("LineflyInsert", "GruvboxBlue", "GruvboxBg0")
    synthesize_mode_highlight("LineflyVisual", "GruvboxOrange", "GruvboxBg0")
    synthesize_mode_highlight("LineflyCommand", "GruvboxGreen", "GruvboxBg0")
    synthesize_mode_highlight("LineflyReplace", "GruvboxRed", "GruvboxBg0")
  elseif g.colors_name == "retrobox" then
    synthesize_mode_highlight("LineflyNormal", "Structure", "VertSplit")
    synthesize_mode_highlight("LineflyInsert", "Directory", "VertSplit")
    highlight(0, "LineflyVisual", { link = "Visual" })
    synthesize_mode_highlight("LineflyCommand", "MoreMsg", "VertSplit")
    highlight(0, "LineflyReplace", { link = "ErrorMsg" })
  elseif
    g.colors_name == "carbonfox"
    or g.colors_name == "dawnfox"
    or g.colors_name == "duskfox"
    or g.colors_name == "dayfox"
    or g.colors_name == "nightfox"
    or g.colors_name == "nordfox"
    or g.colors_name == "terafox"
  then
    highlight(0, "LineflyNormal", { link = "MiniStatuslineModeOther" })
    highlight(0, "LineflyInsert", { link = "MiniStatuslineModeInsert" })
    highlight(0, "LineflyVisual", { link = "MiniStatuslineModeVisual" })
    highlight(0, "LineflyCommand", { link = "MiniStatuslineModeCommand" })
    highlight(0, "LineflyReplace", { link = "MiniStatuslineModeReplace" })
  elseif g.colors_name == "oxocarbon" then
    highlight(0, "LineflyNormal", { link = "StatusNormal" })
    highlight(0, "LineflyInsert", { link = "StatusInsert" })
    highlight(0, "LineflyVisual", { link = "StatusVisual" })
    highlight(0, "LineflyCommand", { link = "StatusCommand" })
    highlight(0, "LineflyReplace", { link = "StatusReplace" })
  elseif g.colors_name == "tokyodark" then
    highlight(0, "LineflyNormal", { link = "WildMenu" })
    highlight(0, "LineflyInsert", { link = "Search" })
    synthesize_mode_highlight("LineflyVisual", "Number", "VertSplit")
    synthesize_mode_highlight("LineflyCommand", "WarningMsg", "VertSplit")
    synthesize_mode_highlight("LineflyReplace", "Error", "VertSplit")
  elseif g.colors_name == "falcon" then
    synthesize_mode_highlight("LineflyNormal", "Directory", "NonText")
    synthesize_mode_highlight("LineflyInsert", "Done", "NonText")
    synthesize_mode_highlight("LineflyVisual", "javaScriptGlobal", "NonText")
    synthesize_mode_highlight("LineflyCommand", "DiagnosticWarn", "NonText")
    synthesize_mode_highlight("LineflyReplace", "ErrorMsg", "NonText")
  else
    -- Fallback for all other colorschemes.
    if highlight_empty("LineflyNormal") then
      synthesize_mode_highlight("LineflyNormal", "Directory", "VertSplit")
    end
    if highlight_empty("LineflyInsert") then
      synthesize_mode_highlight("LIneflyInsert", "String", "VertSplit")
    end
    if highlight_empty("LineflyVisual") then
      synthesize_mode_highlight("LineflyVisual", "Statement", "VertSplit")
    end
    if highlight_empty("LineflyCommand") then
      synthesize_mode_highlight("LineflyCommand", "WarningMsg", "VertSplit")
    end
    if highlight_empty("LineflyReplace") then
      synthesize_mode_highlight("LineflyReplace", "Error", "VertSplit")
    end
  end
end

local M = {}

M.generate_groups = function()
  if g.colors_name == nil then
    return
  end

  -- Tweak the default Neovim theme to work better with Linefly if it is in effect.
  if g.colors_name == "default" then
    highlight(0, "StatusLine", { link = "StatusLineNC" })
    highlight(0, "WinSeparator", { link = "SignColumn" })
  end

  -- Extract current StatusLine background color, we will likely need it.
  local statusline_reverse = get_highlight(0, { name = "StatusLine", link = false }).reverse
  if statusline_reverse and statusline_reverse == true then
    -- Need to handle reversed highlights, such as Gruvbox StatusLine.
    statusline_bg = get_highlight(0, { name = "StatusLine", link = false }).fg
    statusline_nc_bg = get_highlight(0, { name = "StatusLineNC", link = false }).fg
  else
    -- Most colorschemes fall through to here.
    statusline_bg = get_highlight(0, { name = "StatusLine", link = false }).bg
    statusline_nc_bg = get_highlight(0, { name = "StatusLineNC", link = false }).bg
  end

  -- Mode highlights.
  colorscheme_mode_highlights()

  -- Synthesize emphasis colors from the existing mode colors.
  synthesize_highlight("LineflyNormalEmphasis", "LineflyNormal", true)
  synthesize_highlight("LineflyInsertEmphasis", "LineflyInsert", true)
  synthesize_highlight("LineflyVisualEmphasis", "LineflyVisual", true)
  synthesize_highlight("LineflyCommandEmphasis", "LineflyCommand", true)
  synthesize_highlight("LineflyReplaceEmphasis", "LineflyReplace", true)

  -- Synthesize plugin colors from relevant existing highlight groups.
  colorscheme_git_highlights()
  colorscheme_diagnostic_highlights()
  highlight(0, "LineflySession", { link = "LineflyGitAdd" })

  if options().tabline and highlight_empty("TablineSelSymbol") then
    highlight(0, "TablineSelSymbol", { link = "TablineSel" })
  end

  -- Invalidate the file icon cache; likely because a colorscheme change has
  -- occurred.
  file_icon_highlight_cache = {}
end

M.generate_icon_group = function(custom_icon_highlight, icon_highlight, context)
  -- Check if the custom highlight group already exists in the cache.
  local cached_icon_highlight = file_icon_highlight_cache[custom_icon_highlight]
  if cached_icon_highlight then
    -- No need to do anything, custom highlight group already exists.
    return
  end

  -- Extract the foreground color of the file icon.
  local source_fg = get_highlight(0, { name = icon_highlight, link = false }).fg

  if context == location.WinBar then
    if highlight_empty("WinBar") then
      -- Some themes do not set the WinBar highlight group, so just link to the
      -- base DevIcon highlight group.
      highlight(0, custom_icon_highlight, { link = icon_highlight })
    else
      -- Use the theme's WinBar background color.
      local winbar_bg = get_highlight(0, { name = "WinBar", link = false }).bg
      highlight(0, custom_icon_highlight, { bg = winbar_bg, fg = source_fg })
    end
  elseif context == location.InactiveStatusLine then
    -- Custom icon highlight for the inactive StatusLineNC.
    highlight(0, custom_icon_highlight, { bg = statusline_nc_bg, fg = source_fg })
  else
    -- Custom icon highlight must be for the active StatusLine.
    highlight(0, custom_icon_highlight, { bg = statusline_bg, fg = source_fg })
  end

  -- And lastly add the new highlight to the cache.
  file_icon_highlight_cache[custom_icon_highlight] = icon_highlight
end

return M
