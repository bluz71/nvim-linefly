local g = vim.g
local mode = vim.api.nvim_get_mode
local tabpagenr = vim.fn.tabpagenr

local modes_map = {
  ["n"] = { "%#LineflyNormal#", " normal ", "%#LineflyNormalEmphasis#" },
  ["i"] = { "%#LineflyInsert#", " insert ", "%#LineflyInsertEmphasis#" },
  ["R"] = { "%#LineflyReplace#", " r-mode ", "%#LineflyReplaceEmphasis#" },
  ["v"] = { "%#LineflyVisual#", " visual ", "%#LineflyVisualEmphasis#" },
  ["V"] = { "%#LineflyVisual#", " v-line ", "%#LineflyVisualEmphasis#" },
  ["<C-v>"] = { "%#LineflyVisual#", " v-rect ", "%#LineflyVisualEmphasis#" },
  ["c"] = { "%#LineflyCommand#", " c-mode ", "%#LineflyCommandEmphasis#" },
  ["s"] = { "%#LineflyVisual#", " select ", "%#LineflyVisualEmphasis#" },
  ["S"] = { "%#LineflyVisual#", " s-line ", "%#LineflyVisualEmphasis#" },
  ["<C-s>"] = { "%#LineflyVisual#", " s-rect ", "%#LineflyVisualEmphasis#" },
  ["t"] = { "%#LineflyInsert#", " t-mode ", "%#LineflyInsertEmphasis#" },
}

local M = {}

_G.linefly = M

------------------------------------------------------------
-- Tab-line
------------------------------------------------------------
M.active_tabline = function()
  local symbol = g.lineflyAsciiShapes and "*" or "▪"
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

------------------------------------------------------------
-- Status-line
------------------------------------------------------------
M.active_statusline = function()
  local current_mode = mode().mode
  local divider = g.lineflyAsciiShapes and "|" or "⎪"
  local arrow = g.lineflyAsciiShape and "" or "↓"
  -- let l:git_branch = linefly#GitBranch()
  local mode_emphasis = modes_map[current_mode][3]

  local statusline = modes_map[current_mode][1]
  statusline = statusline .. modes_map[current_mode][2]
  -- let l:statusline .= '%* %<%{linefly#File()}'
  -- let l:statusline .= "%{&modified ? '+\ ' : ' \ \ '}"
  -- let l:statusline .= "%{&readonly ? 'RO\ ' : ''}"
  -- if len(l:git_branch) > 0
  --     let l:statusline .= '%*' . l:divider . l:mode_emphasis
  --     let l:statusline .= l:git_branch . '%* '
  -- endif
  -- let l:statusline .= linefly#PluginsStatus()
  -- let l:statusline .= '%*%=%l:%c %*' . l:divider
  -- let l:statusline .= '%* ' . l:mode_emphasis . '%L%* ' . l:arrow . '%P '
  -- if g:lineflyWithIndentStatus
  --     let l:statusline .= '%*' . l:divider
  --     let l:statusline .= '%* %{linefly#IndentStatus()} '
  -- endif
  --
  return statusline
end

M.tabline = function()
  if g.lineflyTabLine then
    vim.o.tabline = "%!v:lua.linefly.active_tabline()"
  end
end

return M
