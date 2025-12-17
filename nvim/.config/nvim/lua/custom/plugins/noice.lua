return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    cmdline = {
      enabled = true,
      view = 'cmdline_popup', -- This creates the centered textbox
    },
    lsp = {
      -- Disable LSP progress to prevent nil token errors with Neovim 0.11.x
      progress = {
        enabled = false,
      },
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
}
