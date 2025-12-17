return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  cmd = {
    'ObsidianOpen',
    'ObsidianNew',
    'ObsidianQuickSwitch',
    'ObsidianFollowLink',
    'ObsidianBacklinks',
    'ObsidianTags',
    'ObsidianToday',
    'ObsidianYesterday',
    'ObsidianTomorrow',
    'ObsidianDailies',
    'ObsidianSearch',
    'ObsidianLink',
    'ObsidianTemplate',
    'ObsidianRename',
    'ObsidianWorkspace',
  },
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
  },
  keys = {
    -- Note creation and navigation
    { '<leader>on', '<cmd>ObsidianNew<cr>', desc = 'New Obsidian note' },
    { '<leader>oo', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Open Obsidian note (telescope)' },
    { '<leader>of', '<cmd>ObsidianFollowLink<cr>', desc = 'Follow Obsidian link' },
    { '<leader>ob', '<cmd>ObsidianBacklinks<cr>', desc = 'Show backlinks' },

    -- Daily notes
    { '<leader>ot', '<cmd>ObsidianToday<cr>', desc = "Today's note" },
    { '<leader>oy', '<cmd>ObsidianYesterday<cr>', desc = "Yesterday's note" },
    { '<leader>om', '<cmd>ObsidianTomorrow<cr>', desc = "Tomorrow's note" },
    { '<leader>od', '<cmd>ObsidianDailies<cr>', desc = 'Daily notes' },

    -- Search and tags (using telescope)
    { '<leader>os', '<cmd>ObsidianSearch<cr>', desc = 'Search notes content (telescope)' },
    {
      '<leader>og',
      function()
        require('obsidian').util.grep_notes()
      end,
      desc = 'Grep notes with telescope',
    },
    {
      '<leader>ox',
      function()
        require('obsidian').util.pick_tags()
      end,
      desc = 'Show tags (telescope)',
    },

    -- Templates and utilities
    { '<leader>or', '<cmd>ObsidianRename<cr>', desc = 'Rename note' },
    { '<leader>ow', '<cmd>ObsidianWorkspace<cr>', desc = 'Switch workspace' },

    -- Quick actions (buffer-specific)
    {
      'gf',
      function()
        return require('obsidian').util.gf_passthrough()
      end,
      desc = 'Follow link',
      ft = 'markdown',
    },
    {
      '<leader>ch',
      function()
        return require('obsidian').util.toggle_checkbox()
      end,
      desc = 'Toggle checkbox',
      ft = 'markdown',
    },
    { '<leader>ol', '<cmd>ObsidianLink<cr>', desc = 'Create link', mode = 'v', ft = 'markdown' },
    { '<leader>oln', '<cmd>ObsidianLinkNew<cr>', desc = 'Create new link', mode = 'v', ft = 'markdown' },
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/Documents/Obsidian/personal',
      },
      {
        name = 'work',
        path = '~/Documents/Obsidian/zinderlabs',
      },
    },

    -- Use telescope for obsidian's built-in pickers
    picker = {
      name = 'telescope.nvim',
      note_mappings = {
        new = '<C-y>',
        insert_link = '<C-l>',
      },
      tag_mappings = {
        tag_note = '<C-t>',
        insert_tag = '<C-i>',
      },
    },

    -- Note configuration
    note_id_func = function(title)
      local suffix = ''
      if title ~= nil then
        suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        suffix = tostring(os.time())
      end
      return suffix
    end,

    note_path_func = function(spec)
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix '.md'
    end,

    note_frontmatter_func = function(note)
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    -- Daily notes configuration
    daily_notes = {
      folder = 'daily',
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      default_tags = { 'daily-notes' },
      template = nil,
    },

    -- Completion configuration - UPDATED FOR TAGS AND LINKS ONLY
    completion = {
      nvim_cmp = true,
      min_chars = 2,
      -- Ensure proper link insertion
      new_notes_location = 'current_dir',
      prepend_note_id = true,
      prepend_note_path = false,
      use_path_only = false,
    },

    -- Link configuration
    follow_url_func = function(url)
      vim.fn.jobstart { 'open', url } -- macOS
      -- vim.fn.jobstart({"xdg-open", url})  -- Linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    end,

    -- Custom attachment configuration
    attachments = {
      img_folder = 'assets/imgs',
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format('![%s](%s)', path.name, path)
      end,
    },

    -- UI configuration
    ui = {
      enable = true,
      update_debounce = 200,
      max_file_length = 5000,
      checkboxes = {
        [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
        ['x'] = { char = '', hl_group = 'ObsidianDone' },
        ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
        ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
        ['!'] = { char = '', hl_group = 'ObsidianImportant' },
      },
      bullets = { char = '•', hl_group = 'ObsidianBullet' },
      external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
      reference_text = { hl_group = 'ObsidianRefText' },
      highlight_text = { hl_group = 'ObsidianHighlightText' },
      tags = { hl_group = 'ObsidianTag' },
      block_ids = { hl_group = 'ObsidianBlockID' },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = '#f78c6c' },
        ObsidianDone = { bold = true, fg = '#89ddff' },
        ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
        ObsidianTilde = { bold = true, fg = '#ff5370' },
        ObsidianImportant = { bold = true, fg = '#d73128' },
        ObsidianBullet = { bold = true, fg = '#89ddff' },
        ObsidianRefText = { underline = true, fg = '#c792ea' },
        ObsidianExtLinkIcon = { fg = '#c792ea' },
        ObsidianTag = { italic = true, fg = '#89ddff' },
        ObsidianBlockID = { italic = true, fg = '#89ddff' },
        ObsidianHighlightText = { bg = '#75662e' },
      },
    },

    -- Mappings
    mappings = {
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ['<leader>ch'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      ['<cr>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },

    log_level = vim.log.levels.INFO,
    open_notes_in = 'current',
  },

  config = function(_, opts)
    require('obsidian').setup(opts)
    -- Add this at the end of your config function
    require('tmux-obsidian-status').setup()
    -- Setup nvim-cmp for obsidian - TAGS AND LINKS ONLY
    local cmp_ok, cmp = pcall(require, 'cmp')
    if cmp_ok then
      -- Configure cmp specifically for markdown files with ONLY obsidian sources
      cmp.setup.filetype('markdown', {
        sources = cmp.config.sources {
          -- Only obsidian sources for tags and links
          { name = 'obsidian', priority = 1000 },
          { name = 'obsidian_new', priority = 900 },
          { name = 'obsidian_tags', priority = 800 },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          -- Ensure proper link insertion on confirm
          ['<CR>'] = cmp.mapping.confirm {
            select = true,
            behavior = cmp.ConfirmBehavior.Insert,
          },
          ['<Tab>'] = cmp.mapping.confirm {
            select = true,
            behavior = cmp.ConfirmBehavior.Insert,
          },
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
        },
        -- Ensure proper formatting for obsidian completions
        formatting = {
          format = function(entry, vim_item)
            -- Show source type in completion menu
            if entry.source.name == 'obsidian' then
              vim_item.menu = '[Link]'
            elseif entry.source.name == 'obsidian_new' then
              vim_item.menu = '[New]'
            elseif entry.source.name == 'obsidian_tags' then
              vim_item.menu = '[Tag]'
            end
            return vim_item
          end,
        },
        -- Ensure completion triggers for obsidian syntax
        completion = {
          autocomplete = {
            require('cmp.types').cmp.TriggerEvent.TextChanged,
          },
          completeopt = 'menu,menuone,noselect',
        },
      })

      -- Custom completion behavior for obsidian links
      local orig_confirm = cmp.confirm
      cmp.confirm = function(opts)
        local entry = cmp.get_selected_entry()
        if entry and (entry.source.name == 'obsidian' or entry.source.name == 'obsidian_new') then
          -- Ensure we get the full completion item with proper link formatting
          opts = opts or {}
          opts.behavior = cmp.ConfirmBehavior.Insert
        end
        return orig_confirm(opts)
      end
    end

    -- Custom telescope functions
    local obsidian_utils = require('obsidian').util

    function obsidian_utils.grep_notes()
      local obsidian = require 'obsidian'
      local client = obsidian.get_client()
      if not client then
        vim.notify('No active Obsidian workspace', vim.log.levels.ERROR)
        return
      end

      local workspace_path = client.dir.filename
      require('telescope.builtin').live_grep {
        cwd = workspace_path,
        glob_pattern = '*.md',
        prompt_title = 'Search Obsidian Notes',
      }
    end

    function obsidian_utils.pick_tags()
      local obsidian = require 'obsidian'
      local client = obsidian.get_client()
      if not client then
        vim.notify('No active Obsidian workspace', vim.log.levels.ERROR)
        return
      end

      local tags = {}
      local tag_set = {}
      local workspace_path = client.dir.filename
      local notes = vim.fn.globpath(workspace_path, '**/*.md', false, true)

      for _, note_path in ipairs(notes) do
        local content = vim.fn.readfile(note_path)
        for _, line in ipairs(content) do
          for tag in line:gmatch '#([%w_-]+)' do
            if not tag_set[tag] then
              tag_set[tag] = true
              table.insert(tags, '#' .. tag)
            end
          end
        end
      end

      if #tags == 0 then
        vim.notify('No tags found in workspace', vim.log.levels.INFO)
        return
      end

      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new({}, {
          prompt_title = 'Obsidian Tags (' .. #tags .. ' found)',
          finder = finders.new_table {
            results = tags,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                require('telescope.builtin').live_grep {
                  cwd = workspace_path,
                  glob_pattern = '*.md',
                  default_text = selection[1],
                  prompt_title = 'Notes with tag: ' .. selection[1],
                }
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Set up autocommands
    local group = vim.api.nvim_create_augroup('ObsidianNvim', { clear = true })

    vim.api.nvim_create_autocmd('InsertLeave', {
      group = group,
      pattern = '*.md',
      callback = function()
        if vim.bo.modified then
          vim.cmd 'silent! write'
        end
      end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'markdown',
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = ''
      end,
    })
  end,
}
