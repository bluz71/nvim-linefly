local opt = vim.opt

local M = {}

M.is_empty = function(str)
  return str == nil or string.len(str) == 0
end

M.is_present = function(str)
  return str and string.len(str) > 0
end

M.indent_status = function()
  if not opt.expandtab:get() then
    return "Tab:" .. opt.tabstop:get() .. " "
  else
    local size = opt.shiftwidth:get()
    if size == 0 then
      size = opt.tabstop:get()
    end
    return "Spc:" .. size .. " "
  end
end

return M
