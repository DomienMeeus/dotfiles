-- ~/.config/nvim/lua/tmux-obsidian-status.lua
-- Lua script to get current obsidian workspace for tmux

local M = {}

-- Function to get current obsidian workspace
function M.get_current_workspace()
  local ok, obsidian = pcall(require, 'obsidian')
  if not ok then
    return nil
  end

  local client = obsidian.get_client()
  if client and client.current_workspace then
    return client.current_workspace.name
  end

  return nil
end

-- Function to write workspace to a temp file for tmux to read
function M.write_workspace_for_tmux()
  local workspace = M.get_current_workspace()
  local temp_file = '/tmp/nvim-obsidian-workspace'

  local file = io.open(temp_file, 'w')
  if file then
    if workspace then
      file:write(workspace .. ' < 󰏪 ')
    else
      file:write ''
    end
    file:close()
  end
end

-- Auto-update the workspace file when switching workspaces
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('TmuxObsidianStatus', { clear = true })

  -- Update when entering a buffer or changing workspace
  vim.api.nvim_create_autocmd({ 'BufEnter', 'VimEnter' }, {
    group = group,
    callback = function()
      -- Delay slightly to ensure obsidian is loaded
      vim.defer_fn(M.write_workspace_for_tmux, 100)
    end,
  })

  -- Also update when obsidian workspace changes
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'ObsidianWorkspaceChanged',
    callback = M.write_workspace_for_tmux,
  })
end

-- Initialize
function M.setup()
  setup_autocmds()
  M.write_workspace_for_tmux()
end

-- For command-line usage
if vim.v.servername then
  M.setup()
end

return M
