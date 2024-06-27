local file = require("linefly.file")
local location = require("linefly.constants").location
local options = require("linefly.options").list
local utils = require("linefly.utils")
local window = require("linefly.window")
local buf_get_option = vim.api.nvim_buf_get_option
local fn = vim.fn
local fnamemodify = fn.fnamemodify
local mode = vim.api.nvim_get_mode
local opt = vim.opt
local opt_local = vim.opt_local
local pathshorten = fn.pathshorten
local tabpagenr = fn.tabpagenr
local win_get_height = vim.api.nvim_win_get_height

-- Refer to ':help mode()' for the full list of available modes. For now only
-- handle the most common modes.
local modes_map = setmetatable({
  ["n"] = { "%#LineflyNormal#", " normal ", "%#LineflyNormalEmphasis#" }, -- Normal
  ["no"] = { "%#LineflyNormal#", " o-pend ", "%#LineflyNormalEmphasis#" }, -- Operator pending
  ["niI"] = { "%#LineflyNormal#", " i-pend ", "%#LineflyNormalEmphasis#" }, -- Insert mode pending (Ctrl-o)
  ["niR"] = { "%#LineflyNormal#", " r-pend ", "%#LineflyNormalEmphasis#" }, -- Replace mode pending (Ctrl-o)
  ["i"] = { "%#LineflyInsert#", " insert ", "%#LineflyInsertEmphasis#" }, -- Insert
  ["ic"] = { "%#LineflyInsert#", " i-comp ", "%#LineflyInsertEmphasis#" }, -- Insert completion (generic)
  ["ix"] = { "%#LineflyInsert#", " i-comp ", "%#LineflyInsertEmphasis#" }, -- Insert completion (Ctrl-x)
  ["v"] = { "%#LineflyVisual#", " visual ", "%#LineflyVisualEmphasis#" }, -- Visual (v)
  ["vs"] = { "%#LineflyVisual#", " visual ", "%#LineflyVisualEmphasis#" }, -- Visual (Ctrl-o select mode)
  ["V"] = { "%#LineflyVisual#", " v-line ", "%#LineflyVisualEmphasis#" }, -- Visual line (V)
  ["Vs"] = { "%#LineflyVisual#", " v-line ", "%#LineflyVisualEmphasis#" }, -- Visual line (Ctrl-o select mode)
  ["\022"] = { "%#LineflyVisual#", " v-bloc ", "%#LineflyVisualEmphasis#" }, -- Visual block (Ctrl-v)
  ["s"] = { "%#LineflyVisual#", " select ", "%#LineflyVisualEmphasis#" }, -- Select (gh)
  ["S"] = { "%#LineflyVisual#", " s-line ", "%#LineflyVisualEmphasis#" }, -- Select line (gH)
  ["\019"] = { "%#LineflyVisual#", " s-bloc ", "%#LineflyVisualEmphasis#" }, -- Select block (CTRL-S)
  ["c"] = { "%#LineflyCommand#", " c-mode ", "%#LineflyCommandEmphasis#" }, -- Command line
  ["r"] = { "%#LineflyCommand#", " prompt ", "%#LineflyReplaceEmphasis#" }, -- Prompt for 'enter'
  ["rm"] = { "%#LineflyCommand#", " prompt ", "%#LineflyReplaceEmphasis#" }, -- Prompt for 'more'
  ["r?"] = { "%#LineflyCommand#", " prompt ", "%#LineflyReplaceEmphasis#" }, -- Prompt for 'confirmation'
  ["!"] = { "%#LineflyCommand#", "  !-mode ", "%#LineflyReplaceEmphasis#" }, -- Command execution
  ["R"] = { "%#LineflyReplace#", " r-mode ", "%#LineflyReplaceEmphasis#" }, -- Replace
  ["Rc"] = { "%#LineflyReplace#", " r-comp ", "%#LineflyReplaceEmphasis#" }, -- Replace completion (generic)
  ["Rx"] = { "%#LineflyReplace#", " r-comp ", "%#LineflyReplaceEmphasis#" }, -- Replace completion (Ctrl-x)
  ["t"] = { "%#LineflyInsert#", " t-mode ", "%#LineflyInsertEmphasis#" }, -- Terminal
  ["nt"] = { "%#LineflyNormal#", " normal ", "%#LineflyNormalEmphasis#" }, -- Terminal normal mode
}, {
  __index = function()
    return { "%#LineflyNormal#", " normal ", "%#LineflyNormalEmphasis#" } -- Handle edge modes
  end,
})

local M = {}

_G.linefly = M

------------------------------------------------------------
-- Status line
------------------------------------------------------------

M.active_statusline = function(lsp_status)
  local current_mode = mode().mode
  local separator = options().separator_symbol or "⎪"
  local progress = options().progress_symbol or "↓"
  local branch_name = require("linefly.git").current_branch_name()
  local plugins_status = require("linefly.plugins").status()
  local mode_emphasis = modes_map[current_mode][3]
  local statusline_width = window.statusline_width()

  local statusline = modes_map[current_mode][1]
  if statusline_width < 80 then
    -- Use short mode-indicator if the statusline width is less than 80 columns.
    statusline = statusline .. string.sub(modes_map[current_mode][2], 1, 2) .. " "
  else
    statusline = statusline .. modes_map[current_mode][2]
  end
  statusline = statusline .. "%* %<" .. file.name(statusline_width < 120, location.ActiveStatusLine)
  statusline = statusline .. "%q%{exists('w:quickfix_title')? ' ' . w:quickfix_title : ''}"
  statusline = statusline .. "%{&modified ? '+ ' : '  '}"
  statusline = statusline .. "%{&readonly ? 'RO ' : ''}"
  if utils.is_present(branch_name) and statusline_width >= 80 then
    statusline = statusline .. "%*" .. separator .. mode_emphasis
    statusline = statusline .. branch_name .. "%* "
  end
  if utils.is_present(plugins_status) and statusline_width >= 80 then
    statusline = statusline .. plugins_status
    statusline = statusline .. "%*"
  end
  if options().with_attached_clients and statusline_width >= 120 then
    local attached_clients = require("linefly.lsp").attached_clients()
    if utils.is_present(attached_clients) then
      statusline = statusline .. separator .. " " .. attached_clients
    end
  end
  if options().with_lsp_status and utils.is_present(lsp_status)
    and opt.laststatus:get() == 3 and statusline_width >= 120 then
    -- Note, LSP progress status is propagated down from an LspProgress event.
    statusline = statusline .. "%=" .. lsp_status
  end
  -- Right-hand side section.
  statusline = statusline .. "%="
  if fn.has("nvim-0.9") and opt.showcmdloc:get() == "statusline"
    and opt.showcmd:get() and statusline_width >= 80 then
    statusline = statusline .. "%S " .. separator .. " "
  end
  if options().with_macro_status and statusline_width >= 80 then
    local recording_register = fn.reg_recording()
    if utils.is_present(recording_register) then
      statusline = statusline .. "%#LineflySession#recording @"
      statusline = statusline .. recording_register .. "%* " .. separator .. " "
    end
  end
  if options().with_search_count and vim.v.hlsearch == 1 and statusline_width >= 80 then
    local search_count = utils.search_count()
    if utils.is_present(search_count) then
      statusline = statusline .. search_count .. " " .. separator .. " "
    end
  end
  if options().with_spell_status and opt.spell:get() and statusline_width >= 80 then
    statusline = statusline .. "Spell " .. separator .. " "
  end
  statusline = statusline .. "%l:%c " .. separator
  statusline = statusline .. " " .. mode_emphasis .. "%L%* " .. progress .. "%P "
  if options().with_indent_status then
    statusline = statusline .. separator .. " " .. utils.indent_status()
  end

  return statusline
end

M.inactive_statusline = function()
  local separator = options().separator_symbol or "⎪"
  local progress = options().progress_symbol or "↓"

  local statusline = " %<" .. file.name(window.statusline_width() <= 120, location.InactiveStatusLine)
  statusline = statusline .. "%{&modified?'+ ':'  '}"
  statusline = statusline .. "%{&readonly?'RO ':''}"
  statusline = statusline .. "%=%l:%c " .. separator .. " %L " .. progress .. "%P "
  if options().with_indent_status then
    statusline = statusline .. separator .. " " .. utils.indent_status()
  end

  return statusline
end

M.statusline = function(active, lsp_status)
  local bt = buf_get_option(0, "buftype")
  local ft = buf_get_option(0, "filetype")

  if bt == "nofile" or ft == "netrw" or ft == "oil" then
    if string.sub(ft, 1, 5) == "dapui" then
      -- This is an nvim-dap-ui window; hence, configure a simple statusline
      -- and winbar (if needed) for this type of debugger window.
      opt_local.statusline = " %f"
      if opt.laststatus:get() == 3 and options().winbar then
        opt_local.winbar = "%{%v:lua.linefly.inactive_winbar()%}"
      else
        opt_local.winbar = nil
      end
      return
    end
    -- Else, likely a file explorer or some other special type of buffer. Set a
    -- short path statusline for these types of buffers.
    opt_local.statusline = pathshorten(fnamemodify(vim.fn.getcwd(), ":~:."))
    if options().winbar then
      opt_local.winbar = nil
    end
  elseif bt == "nowrite" then
    -- Do not set statusline and winbar for certain special windows.
    return
  elseif window.is_floating() then
    -- Do not set statusline and winbar for floating windows.
    return
  elseif active then
    if utils.is_present(lsp_status) then
      opt_local.statusline = "%{%v:lua.linefly.active_statusline('" .. lsp_status .. "')%}"
    else
      opt_local.statusline = "%{%v:lua.linefly.active_statusline()%}"
    end
    if options().winbar and window.count() > 1 then
      opt_local.winbar = "%{%v:lua.linefly.active_winbar()%}"
    else
      opt_local.winbar = nil
    end
  else
    opt_local.statusline = "%{%v:lua.linefly.inactive_statusline()%}"
    if options().winbar and window.count() > 1 and win_get_height(0) > 1 then
      opt_local.winbar = "%{%v:lua.linefly.inactive_winbar()%}"
    else
      opt_local.winbar = nil
    end
  end
end

------------------------------------------------------------
-- Window bar
------------------------------------------------------------

M.active_winbar = function()
  local current_mode = mode().mode

  local winbar = modes_map[current_mode][1]
  winbar = winbar .. string.sub(modes_map[current_mode][2], 1, 2)
  winbar = winbar .. " %* %<" .. file.name(true, location.WinBar)
  winbar = winbar .. "%{&modified ? '+ ' : '  '}"
  winbar = winbar .. "%{&readonly ? 'RO ' : ''}"
  winbar = winbar .. "%#Normal#"

  return winbar
end

M.inactive_winbar = function()
  local winbar = " %<" .. file.name(true, location.WinBar)
  winbar = winbar .. "%{&modified?'+ ':'  '}"
  winbar = winbar .. "%{&readonly?'RO ':''}"
  winbar = winbar .. "%#NonText#"

  return winbar
end

------------------------------------------------------------
-- Tab line
------------------------------------------------------------

M.active_tabline = function()
  local symbol = options().active_tab_symbol or "▪"
  local tabline = ""
  local counter = 0

  for _ = 1, tabpagenr("$"), 1 do
    counter = counter + 1
    tabline = tabline .. "%" .. counter .. "T"
    if tabpagenr() == counter then
      tabline = tabline .. "%#TablineSelSymbol#" .. symbol .. "%#TablineSel# Tab:"
    else
      tabline = tabline .. "%#TabLine#  Tab:"
    end
    tabline = tabline .. counter .. "%T" .. "  %#TabLineFill#"
  end

  return tabline
end

M.tabline = function()
  if options().tabline then
    vim.opt.tabline = "%{%v:lua.linefly.active_tabline()%}"
  end
end

return M
