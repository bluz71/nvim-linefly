local is_present = require("linefly.utils").is_present
local options = require("linefly.options").list
local diagnostic = vim.diagnostic
local eval = vim.api.nvim_eval
local g = vim.g

local M = {}

M.status = function()
  local segments = ""

  -- Git status.
  if options().with_git_status and package.loaded.gitsigns then
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
    local error_symbol = options().error_symbol or "E"
    local warning_symbol = options().warning_symbol or "W"
    local information_symbol = options().information_symbol or "I"

    if errors > 0 then
      segments = segments .. " %#LineflyDiagnosticError#" .. error_symbol
      segments = segments .. " " .. errors .. "%*"
    end
    if warnings > 0 then
      segments = segments .. " %#LineflyDiagnosticWarning#" .. warning_symbol
      segments = segments .. " " .. warnings .. "%*"
    end
    if information > 0 then
      segments = segments .. " %#LineflyDiagnosticInformation#" .. information_symbol
      segments = segments .. " " .. information .. "%*"
    end
    if errors > 0 or warnings > 0 or information > 0 then
      segments = segments .. " "
    end
  end

  -- Session status.
  local session_segment
  if options().with_session_status and g.loaded_obsession then
    session_segment = eval([[ObsessionStatus('obsession', '!obsession')]])
  elseif options().with_session_status and package.loaded.possession then
    session_segment = require("possession.session").session_name
  elseif options().with_session_status and package.loaded["nvim-possession"] then
    session_segment = require("nvim-possession").status()
  end
  if is_present(session_segment) then
    segments = segments .. " %#LineflySession#" .. session_segment .. "%*"
  end

  return segments
end

return M
