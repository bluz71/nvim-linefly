local g = vim.g
local tabpagenr = vim.fn.tabpagenr

local modes = {
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

------------------------------------------------------------
-- Tab-line
------------------------------------------------------------
function LineflyActiveTabline()
  local symbol = "▪"
  local tabline = ""
  local counter = 0

  if g.lineflyAsciiShapes then
    symbol = "*"
  end

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

local M = {}

M.tabline = function()
  if g.lineflyTabLine then
    vim.o.tabline = "%!v:lua.LineflyActiveTabline()"
  end
end

return M
