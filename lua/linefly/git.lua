local is_empty = require("linefly.utils").is_empty
local b = vim.b
local buf_get_name = vim.api.nvim_buf_get_name
local g = vim.g
local system = vim.fn.system

local M = {}

M.current_branch_name = function()
  if not g.lineflyWithGitBranch or buf_get_name(0) == "" then
    return ""
  end

  local git_branch_name

  if package.loaded.gitsigns ~= nil then
    -- Gitsigns is available, let's use it to get the branch name since it is
    -- readily accessible.
    git_branch_name = b.gitsigns_head
  else
    -- Else use the fallback detection path.
    git_branch_name = b.git_branch_name
  end

  if is_empty(git_branch_name) then
    return ""
  end

  if g.lineflyAsciiShapes then
    return " " .. git_branch_name
  else
    return "  " .. git_branch_name
  end

  return git_branch_name
end

-- Detect the branch name using an old-school system call. This function will
-- only be called upon BufEnter and FocusGained events to avoid needlessly
-- invoking that system call every time the statusline is redrawn.
M.detect_branch_name = function()
  local git_branch_name = system("git branch --show-current 2> /dev/null")

  if is_empty(git_branch_name) then
    return ""
  else
    return string.gsub(git_branch_name, "\n", "")
  end
end

return M
