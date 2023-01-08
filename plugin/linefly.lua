-- A simple Vim / Neovim statusline.
--
-- URL:          github.com/bluz71/nvim-linefly
-- License:      MIT (https://opensource.org/licenses/MIT)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local g = vim.g

if vim.g.linefly ~= nil then
  return
end
vim.g.linefly = 1


-- By default do not use Ascii character shapes for dividers and symbols.
g.lineflyAsciiShapes = g.lineflyAsciiShapes or false

-- The symbol used to indicate the presence of errors in the current buffer. By
-- default the x character will be used.
g.lineflyErrorSymbol = g.lineflyErrorSymbo or 'x'

-- The symbol used to indicate the presence of warnings in the current buffer. By
-- default the exclamation symbol will be used.
g.lineflyWarningSymbol = g.lineflyWarningSymbol or '!'

-- The symbol used to indicate the presence of information in the current buffer.
-- By default the 'i' character will be used.
g.lineflyInformationSymbol = g.lineflyWarningSymbol or 'i'

-- By default do not enable tabline support.
g.lineflyTabLine = g.lineflyTabLine or false

-- By default do not enable Neovim's winbar support.
g.lineflyWinBar = g.lineflyWinBar or false

-- By default do not display indentation details.
g.lineflyWithIndentStatus = g.lineflyWithIndentStatus or false

-- By default display Git branches.
g.lineflyWithGitBranch = g.lineflyWithGitBranch or true

-- By default display Gitsigns status, if the plugin is loaded.
g.lineflyWithGitsignsStatus = g.lineflyWithGitsignsStatus or true

-- By default don't display a filetype icon.
g.lineflyWithFileIcon = g.lineflyWithFileIcon or false

-- By default do indicate Neovim Diagnostic status, if nvim-lsp plugin is loaded.
g.lineflyWithNvimDiagnosticStatus = g.lineflyWithNvimDiagnosticStatus or true

-- By default do indicate ALE lint status, if the plugin is loaded.
g.lineflyWithALEStatus = g.lineflyWithALEStatus or true

-- By default do indicate Coc diagnostic status, if the plugin is loaded.
g.lineflyWithCocStatus = g.lineflyWithCocStatus or true

local linefly_events = augroup("LineflyEvents", {})

autocmd({"VimEnter", "ColorScheme"}, {
  command = "call linefly#GenerateHighlightGroups()",
  group = linefly_events
})

autocmd("VimEnter", {
  command = "call linefly#UpdateInactiveWindows()",
  group = linefly_events
})

autocmd("VimEnter", {
  command = "call linefly#TabLine()",
  group = linefly_events
})

autocmd("VimEnter", {
  command = "call linefly#TabLine()",
  group = linefly_events
})

autocmd({"WinEnter", "BufWinEnter"}, {
  command = "call linefly#StatusLine(v:true)",
  group = linefly_events
})

autocmd("WinLeave", {
  command = "call linefly#StatusLine(v:false)",
  group = linefly_events
})
