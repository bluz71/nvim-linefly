local options = require("linefly.options").list
local o = vim.o
local format = string.format

local M = {}

M.is_empty = function(str)
  return str == nil or string.len(str) == 0
end

M.is_present = function(str)
  return str and string.len(str) > 0
end

M.truncate = function(str)
  if #str > 30 then
    return string.sub(str, 1, 29) .. options().ellipsis_symbol
  else
    return str
  end
end

M.indent_status = function()
  if not o.expandtab then
    return "Tab:" .. o.tabstop .. " "
  else
    local size = o.shiftwidth
    if size == 0 then
      size = o.tabstop
    end
    return "Spc:" .. size .. " "
  end
end

M.search_count = function()
  local ok, result = pcall(vim.fn.searchcount, { recompute = 1, maxcount = 0 })

  if not ok or not result then -- failed search
    return ""
  elseif result.total == 0 then -- no matches
    return ""
  elseif result.incomplete == 1 then -- timed out
    return "[?/??]"
  elseif result.incomplete == 2 then -- max count exceeded
    if result.total > result.maxcount and result.current > result.maxcount then
      return format("[>%d/>%d]", result.current, result.total)
    elseif result.total > result.maxcount then
      return format("[%d/>%d]", result.current, result.total)
    end
  end

  return format("[%d/%d]", result.current, result.total)
end

return M
