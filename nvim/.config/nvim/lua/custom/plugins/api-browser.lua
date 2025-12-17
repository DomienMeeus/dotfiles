return {
  'tlj/api-browser.nvim',
  dependencies = {
    'kkharji/sqlite.lua',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('api-browser').setup()
  end,
  keys = {
    { '<leader>saa', '<cmd>ApiBrowser open<cr>', desc = 'Select an API.' },
    { '<leader>sad', '<cmd>ApiBrowser select_local_server<cr>', desc = 'Select environment.' },
    { '<leader>sax', '<cmd>ApiBrowser select_remote_server<cr>', desc = 'Select remote environment.' },
    { '<leader>sae', '<cmd>ApiBrowser endpoints<cr>', desc = 'Open list of endpoints for current API.' },
    { '<leader>sar', '<cmd>ApiBrowser recents<cr>', desc = 'Open list of recently opened API endpoints.' },
    { '<leader>sag', '<cmd>ApiBrowser endpoints_with_param<cr>', desc = 'Open API endpoints valid for replacement text on cursor.' },
  },
}
