-- A simple Neovim statusline.
--
-- URL:      github.com/bluz71/nvim-linefly
-- License:  MIT (https://opensource.org/licenses/MIT)

if vim.fn.has("nvim-0.10") ~= 1 then
  vim.api.nvim_echo({ { "nvim-linefly requires Neovim 0.10, or later", "WarningMsg" } }, false, {})
  return
end

local g = vim.g
if g.lineflyLoaded ~= nil then
  return
end
g.lineflyLoaded = true

local linefly = require("linefly")
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local linefly_events = augroup("LineflyEvents", {})

autocmd({ "VimEnter", "ColorScheme" }, {
  callback = function()
    require("linefly.highlight").generate_groups()
  end,
  group = linefly_events,
})

autocmd("VimEnter", {
  callback = function()
    require("linefly.window").update_inactive()
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

autocmd({ "BufEnter", "BufWrite", "FocusGained" }, {
  callback = function()
    if package.loaded.gitsigns == nil then
      -- Gitsigns is not loaded, use fallback Git branch name detection.
      vim.b.git_branch_name = require("linefly.git").detect_branch_name()
    end
  end,
  group = linefly_events,
})

autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
  callback = function()
    linefly.statusline(true)
  end,
  group = linefly_events,
})

autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function()
    linefly.statusline(true)
  end,
  group = linefly_events,
})

autocmd("LspProgress", {
  callback = function(data)
    local lsp_status = require("linefly.lsp").status(data)
    if lsp_status then
      linefly.statusline(true, lsp_status)
    end
  end,
  group = linefly_events,
})
