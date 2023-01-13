-- A simple Vim / Neovim statusline.
--
-- URL:          github.com/bluz71/nvim-linefly
-- License:      MIT (https://opensource.org/licenses/MIT)

if vim.g.lineflyLoaded ~= nil then
  return
end
vim.g.lineflyLoaded = true

local git = require("linefly.git")
local linefly = require("linefly")
local window = require("linefly.window")
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local b = vim.b
local g = vim.g

-- By default do not use Ascii character shapes for dividers and symbols.
g.lineflyAsciiShapes = g.lineflyAsciiShapes or false

-- The symbol used to indicate the presence of errors in the current buffer. By
-- default the x character will be used.
g.lineflyErrorSymbol = g.lineflyErrorSymbo or "x"

-- The symbol used to indicate the presence of warnings in the current buffer. By
-- default the exclamation symbol will be used.
g.lineflyWarningSymbol = g.lineflyWarningSymbol or "!"

-- The symbol used to indicate the presence of information in the current buffer.
-- By default the 'i' character will be used.
g.lineflyInformationSymbol = g.lineflyWarningSymbol or "i"

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

-- By default do inrequire("linefly")dicate Neovim Diagnostic status, if nvim-lsp plugin is loaded.
g.lineflyWithDiagnosticStatus = g.lineflyWithDiagnosticStatus or true

local linefly_events = augroup("LineflyEvents", {})

autocmd({ "VimEnter", "ColorScheme" }, {
  command = "call linefly#GenerateHighlightGroups()",
  group = linefly_events,
})

autocmd("VimEnter", {
  callback = function()
    window.update_inactive()
  end,
  group = linefly_events,
})

autocmd("VimEnter", {
  callback = function()
    linefly.tabline()
  end,
  group = linefly_events,
})

autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = function()
    linefly.statusline(true)
  end,
  group = linefly_events,
})

autocmd("WinLeave", {
  callback = function()
    linefly.statusline(false)
  end,
  group = linefly_events,
})

autocmd({ "BufEnter", "FocusGained" }, {
  callback = function()
    if package.loaded.gitsigns == nil then
      -- Gitsigns is not loaded, use fallback branch name detection.
      b.git_branch_name = git.detect_branch_name()
    end
  end,
  group = linefly_events,
})
