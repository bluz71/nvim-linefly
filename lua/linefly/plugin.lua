local is_present = require("linefly.utils").is_present
local diagnostic = vim.diagnostic
local eval = vim.api.nvim_eval
local g = vim.g

local M = {}

M.status = function()
  local segments = ""

  -- Gitsigns status.
  if g.lineflyWithGitsignsStatus and package.loaded.gitsigns then
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
  if g.lineflyWithDiagnosticStatus and g.lspconfig then
    local errors = #diagnostic.get(0, { severity = diagnostic.severity.ERROR })
    local warnings = #diagnostic.get(0, { severity = diagnostic.severity.WARN })
    local information = #diagnostic.get(0, { severity = diagnostic.severity.INFO })

    if errors > 0 then
      segments = segments .. " %#LineflyDiagnosticError#" .. g.lineflyErrorSymbol
      segments = segments .. " " .. errors .. "%* "
    end
    if warnings > 0 then
      segments = segments .. " %#LineflyDiagnosticWarning#" .. g.lineflyWarningSymbol
      segments = segments .. " " .. warnings .. "%* "
    end
    if information > 0 then
      segments = segments .. " %#LineflyDiagnosticInformation#" .. g.lineflyInformationSymbol
      segments = segments .. " " .. information .. "%* "
    end
  end

  -- Obsession plugin status.
  if g.loaded_obsession then
    local obsession_segment
    if g.lineflyAsciiShapes then
      obsession_segment = eval([[ObsessionStatus('$', 'S')]])
    else
      obsession_segment = eval([[ObsessionStatus('●', '■')]])
    end
    if is_present(obsession_segment) then
      segments = segments .. " %#LineflySession#" .. obsession_segment .. "%*"
    end
  end

  return segments
end

return M
