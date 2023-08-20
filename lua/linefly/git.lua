local is_empty = require("linefly.utils").is_empty
local is_present = require("linefly.utils").is_present
local options = require("linefly.options").list
local b = vim.b
local buf_get_name = vim.api.nvim_buf_get_name

local M = {}

M.current_branch_name = function()
  if not options().with_git_branch or is_empty(buf_get_name(0)) then
    return ""
  end

  local git_branch_name

  if package.loaded.gitsigns ~= nil then
    -- Gitsigns is available, let's use it to access the branch name. Note,
    -- sometimes on initial buffer load Gitsigns returns a 'nil' HEAD value (I
    -- suspect due to a timing issue); use the fallback detected branch name if
    -- so.
    git_branch_name = b.gitsigns_head or b.git_branch_name
  else
    -- Else use fallback detection.
    git_branch_name = b.git_branch_name
  end

  if is_empty(git_branch_name) then
    return ""
  elseif #git_branch_name > 30 then
    -- Truncate long branch names to 30 characters.
    git_branch_name = string.sub(git_branch_name, 1, 29) .. "…"
  end

  local git_branch_symbol = options().git_branch_symbol or ""
  if is_empty(git_branch_symbol) then
    return " " .. git_branch_name
  else
    return " " .. git_branch_symbol .. " " .. git_branch_name
  end

  return git_branch_name
end

-- Detect the branch name. This function will only be called upon BufEnter,
-- BufWrite and FocusGained events to avoid needlessly invoking a system call
-- every time the statusline is redrawn.
M.detect_branch_name = function()
  if not options().with_git_branch or is_empty(buf_get_name(0)) then
    -- Don't calculate the branch name if it isn't wanted or the buffer is
    -- empty.
    return ""
  end

  -- Use Gitsigns if available and it has a branch value.
  if package.loaded.gitsigns ~= nil and is_present(b.gitsigns_head) then
    return b.gitsigns_head
  end

  -- Benchmark the 'git branch --show-current' system call if required.
  -- local start = vim.loop.hrtime()
  local file_process_handle = io.popen("git branch --show-current 2> /dev/null")
  local git_branch_name = file_process_handle:read("*a")
  file_process_handle:close()
  -- print((vim.loop.hrtime() - start) / 1000000)

  if is_empty(git_branch_name) then
    return ""
  else
    return string.gsub(git_branch_name, "\n", "")
  end
end

return M
