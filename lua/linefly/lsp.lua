local utils = require("linefly.utils")
local options = require("linefly.options").list
local get_current_buf = vim.api.nvim_get_current_buf

local M = {}

M.names = function()
  local buf_lsp_clients = vim.lsp.get_active_clients({ bufnr = get_current_buf() })
  local buf_lsp_names = {}

  if buf_lsp_clients and #buf_lsp_clients > 0 then
    for _, lsp_client in pairs(buf_lsp_clients) do
      table.insert(buf_lsp_names, lsp_client.name or "")
    end
  else
    return
  end

  -- Comma-separate LSP names.
  local lsp_names = table.concat(buf_lsp_names, ", ")

  -- Truncate long LSP names if necessary.
  return utils.truncate(lsp_names)
end

M.status = function(data)
  if not options().with_lsp_status or vim.opt.laststatus:get() ~= 3 then
    -- Exit early if LSP status is not wanted or global statusline is not in
    -- effect.
    return
  end

  local lsp_status
  if data.data.result.value.kind == "end" then
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
end

return M
