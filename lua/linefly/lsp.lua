local utils = require("linefly.utils")
local options = require("linefly.options").list
local get_current_buf = vim.api.nvim_get_current_buf

local M = {}

M.attached_clients = function()
  local buf_attached_clients = {}
  local buf_lsp_clients = vim.lsp.get_active_clients({ bufnr = get_current_buf() })

  if buf_lsp_clients and #buf_lsp_clients > 0 then
    for _, lsp_client in pairs(buf_lsp_clients) do
      table.insert(buf_attached_clients, lsp_client.name or "")
    end
  end

  -- Check if the nvim-lint plugin is loaded and whether any clients are
  -- attached.
  if package.loaded.lint ~= nil then
    local buf_lint_clients = require("lint").linters_by_ft[vim.bo.filetype]
    if buf_lint_clients and #buf_lint_clients > 0 then
      for _, lint_client in pairs(buf_lint_clients) do
        table.insert(buf_attached_clients, lint_client or "")
      end
    end
  end

  -- Exit early if there are no clients attached.
  if #buf_attached_clients == 0 then
    return
  end

  -- Comma-separate language server & linter names.
  local names = table.concat(buf_attached_clients, ", ")

  -- Truncate long language server & linter names if necessary.
  return utils.truncate(names)
end

M.status = function(data)
  if not options().with_lsp_status or vim.opt.laststatus:get() ~= 3 then
    -- Exit early if LSP status is not wanted or global statusline is not in
    -- effect.
    return
  end

  local lsp_status
  if data.data.params.value.kind == "end" then
    return "" -- This will clear out the last LSP status message in the statusline.
  else
    lsp_status = vim.lsp.status()
  end

  if utils.is_present(lsp_status) then
    -- Truncate long LSP status messages if necessary.
    return utils.truncate(lsp_status)
  else
    return lsp_status
  end
  return ""
end

return M
