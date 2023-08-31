local utils = require("linefly.utils")
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

  -- Truncate long LSP names to a max of 30 characters.
  return utils.truncate(lsp_names)
end

return M
