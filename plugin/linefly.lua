-- A simple Vim / Neovim statusline.
--
-- URL:          github.com/bluz71/nvim-linefly
-- License:      MIT (https://opensource.org/licenses/MIT)

if vim.fn.has("nvim-0.8") ~= 1 then
  vim.api.nvim_echo({ { "nvim-linefly requires Neovim 0.8, or later", "WarningMsg" } }, false, {})
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
    -- Only update this inactive statusline when global statusline is not in
    -- effect.
    if vim.opt.laststatus:get() ~= 3 then
      linefly.statusline(false)
    end
  end,
  group = linefly_events,
})

autocmd({ "BufEnter", "BufWrite", "FocusGained" }, {
  callback = function()
    vim.b.git_branch_name = require("linefly.git").detect_branch_name()
  end,
  group = linefly_events,
})

autocmd({ "LspAttach", "LspDetach" }, {
  callback = function()
    linefly.statusline(true)
  end,
  group = linefly_events
})
