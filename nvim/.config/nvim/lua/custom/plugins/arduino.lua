return {
  {
    'yuukiflow/Arduino-Nvim',
    ft = 'arduino',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    init = function()
      -- This runs before the plugin loads
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = '*.ino',
        callback = function()
          vim.bo.filetype = 'arduino-nvim'
        end,
      })
    end,
    config = function()
      require('arduino_nvim').setup {
        default_fqbn = 'arduino:avr:uno',
        default_port = '/dev/ttyUSB0',
      }

      -- Key mappings:
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'arduino',
        callback = function()
          local opts = { buffer = true }
          vim.keymap.set('n', '<leader>ac', ':ArduinoCompile<CR>', opts)
          vim.keymap.set('n', '<leader>au', ':ArduinoUpload<CR>', opts)
          vim.keymap.set('n', '<leader>as', ':ArduinoSerial<CR>', opts)
        end,
      })
    end,
  },
}
