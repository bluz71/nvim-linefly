local is_present = require("linefly.utils").is_present
local options = require("linefly.options").list
local diagnostic = vim.diagnostic
local eval = vim.api.nvim_eval
local g = vim.g

local M = {}

M.status = function()
  local segments = ""

  -- Gitsigns status.
  if options().with_gitsigns_status and package.loaded.gitsigns then
    local signs = vim.b.gitsigns_status_dict
    if signs and signs.added and signs.added > 0 then
      segments = segments .. " %#LineflyGitAdd#+" .. signs.added .. "%*"
    end
    if signs and signs.changed and signs.changed > 0 then
      segments = segments .. " %#LineflyGitChange#~" .. signs.changed .. "%*"
    end
    if signs and signs.removed and signs.removed > 0 then
      segments = segments .. " %#LineflyGitDelete#-" .. signs.removed .. "%*"
    end
    if is_present(segments) then
      segments = segments .. " "
    end
  end

  -- Diagnostic status.
  if options().with_diagnostic_status and g.lspconfig then
    local errors = #diagnostic.get(0, { severity = diagnostic.severity.ERROR })
    local warnings = #diagnostic.get(0, { severity = diagnostic.severity.WARN })
    local information = #diagnostic.get(0, { severity = diagnostic.severity.INFO })

    if errors > 0 then
      segments = segments .. " %#LineflyDiagnosticError#" .. options().error_symbol
      segments = segments .. " " .. errors .. "%* "
    end
    if warnings > 0 then
      segments = segments .. " %#LineflyDiagnosticWarning#" .. options().warning_symbol
      segments = segments .. " " .. warnings .. "%* "
    end
    if information > 0 then
      segments = segments .. " %#LineflyDiagnosticInformation#" .. options().information_symbol
      segments = segments .. " " .. information .. "%* "
    end
  end

  local session_segment
  if g.loaded_obsession then
    -- Obsession plugin.
    session_segment = eval([[ObsessionStatus('obsession', '!obsession')]])
  elseif package.loaded.possession then
    session_segment = require('possession.session').session_name
  end
  if is_present(session_segment) then
    segments = segments .. " %#LineflySession#" .. session_segment .. "%*"
  end

  return segments
end

return M
