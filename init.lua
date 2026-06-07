-- =========================================================
-- Pratyush’s top1  Neovim Setup (2025)(forty2)(kevin)
-- =========================================================

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- General Settings
-- =========================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.cindent = false
vim.opt.filetype = 'on'
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Enable filetype plugins and indentation
vim.cmd [[
  filetype plugin indent on
]]

-- Better JavaScript/TypeScript/React indentation
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    callback = function()
        vim.opt_local.indentexpr = ''
        vim.opt_local.smartindent = true
        vim.opt_local.autoindent = true
    end,
})

-- =========================================================
-- Plugins
-- =========================================================
require('lazy').setup {
    -- Treesitter for syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    'lua',
                    'javascript',
                    'typescript',
                    'tsx',
                    'html',
                    'css',
                    'json',
                    'python',
                    'go',
                    'rust',
                    'prisma',
                    'markdown',
                    'dockerfile',
                    'yaml',
                    'toml',
                    'sql',
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = false }, -- Disable treesitter indent, use vim native
            }
        end,
    },

    -- LSP
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Completion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets', -- Pre-made snippets for many languages

    -- Rust-specific LSP/actions
    {
        'mrcjkb/rustaceanvim',
        version = '^5',
        ft = { 'rust' },
        init = function()
            vim.g.rustaceanvim = {
                tools = {
                    inlay_hints = {
                        auto = true,
                    },
                },
                server = {
                    on_attach = function(_, bufnr)
                        local map = function(keys, func, desc)
                            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Rust: ' .. desc })
                        end

                        map('<leader>rr', '<cmd>RustLsp runnables<cr>', 'Runnables')
                        map('<leader>re', '<cmd>RustLsp explainError<cr>', 'Explain Error')
                        map('<leader>rd', '<cmd>RustLsp debuggables<cr>', 'Debuggables')
                        map('<leader>rh', '<cmd>RustLsp hover actions<cr>', 'Hover Actions')
                    end,
                    default_settings = {
                        ['rust-analyzer'] = {
                            cargo = {
                                allFeatures = true,
                            },
                            check = {
                                command = 'clippy',
                                extraArgs = { '--all-features' },
                            },
                            procMacro = {
                                enable = true,
                            },
                        },
                    },
                },
            }
        end,
    },

    -- Rust dependency helper for Cargo.toml
    {
        'saecki/crates.nvim',
        tag = 'v0.4.0',
        ft = { 'rust', 'toml' },
        config = function()
            require('crates').setup {
                popup = {
                    border = 'rounded',
                },
            }
        end,
    },

    -- Debugging stack for Rust and other languages
    {
        'mfussenegger/nvim-dap',
        keys = {
            { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP Toggle Breakpoint' },
            { '<leader>dc', function() require('dap').continue() end,          desc = 'DAP Continue' },
            { '<leader>do', function() require('dap').step_over() end,         desc = 'DAP Step Over' },
            { '<leader>di', function() require('dap').step_into() end,         desc = 'DAP Step Into' },
            { '<leader>dO', function() require('dap').step_out() end,          desc = 'DAP Step Out' },
            { '<leader>dr', function() require('dap').repl.open() end,         desc = 'DAP REPL' },
            { '<leader>dl', function() require('dap').run_last() end,          desc = 'DAP Run Last' },
        },
    },
    {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
        config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'
            dapui.setup {
                layouts = {
                    {
                        elements = {
                            { id = 'scopes',      size = 0.30 },
                            { id = 'breakpoints', size = 0.20 },
                            { id = 'stacks',      size = 0.25 },
                            { id = 'watches',     size = 0.25 },
                        },
                        size = 40,
                        position = 'left',
                    },
                    {
                        elements = {
                            { id = 'repl',    size = 0.5 },
                            { id = 'console', size = 0.5 },
                        },
                        size = 12,
                        position = 'bottom',
                    },
                },
            }
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated['dapui_config'] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited['dapui_config'] = function()
                dapui.close()
            end
        end,
    },
    {
        'theHamsta/nvim-dap-virtual-text',
        dependencies = { 'mfussenegger/nvim-dap' },
        config = function()
            require('nvim-dap-virtual-text').setup {
                commented = true,
            }
        end,
    },

    -- GitHub Copilot + Copilot Chat
    {
        'github/copilot.vim',
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
        end,
    },
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        branch = 'main',
        dependencies = {
            { 'github/copilot.vim' },
            { 'nvim-lua/plenary.nvim' },
        },
        build = 'make tiktoken',
        opts = {
            model = 'auto', -- Use auto model by default (override with $<model> in chat)
            -- Keep prompt behavior explicit and predictable in chat input.
            chat_autocomplete = true,
            remember_as_sticky = false,
            window = {
                layout = 'vertical',
                width = 0.36,
            },
            -- Prevent visual highlight/selection jumping when switching between code and chat.
            highlight_selection = false,
            -- Enable file access for #file: references
            allow_insecure = true,
            -- Default resources to enable file references
            resources = 'selection',
            mappings = {
                -- Keep <C-h>/<C-l> free for window navigation in every buffer.
                reset = false,
            },
            -- Ensure copilot tools are available for file operations
            tools = {
                'copilot',
            },
        },
    },

    -- Telescope
    'nvim-lua/plenary.nvim',
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('telescope').setup {
                defaults = {
                    layout_strategy = 'horizontal',
                    layout_config = {
                        horizontal = {
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    mappings = {
                        i = {
                            ['<C-u>'] = false,
                            ['<C-d>'] = false,
                        },
                    },
                },
            }
            -- Load telescope extensions
            pcall(require('telescope').load_extension, 'themes')
        end,
    },

    -- UI & Quality of Life
    'nvim-tree/nvim-web-devicons',
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require('nvim-autopairs').setup {}
        end,
    },
    {
        'windwp/nvim-ts-autotag',
        event = 'InsertEnter',
        config = function()
            require('nvim-ts-autotag').setup {
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = true,
                },
            }
        end,
    },
    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
    'numToStr/Comment.nvim',
    'lewis6991/gitsigns.nvim',
    'stevearc/conform.nvim',
    {
        'stevearc/overseer.nvim',
        cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerQuickAction', 'OverseerInfo' },
        config = function()
            require('overseer').setup {
                task_list = {
                    direction = 'bottom',
                    min_height = 10,
                    max_height = 18,
                    default_detail = 1,
                },
            }
        end,
    },
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            require('which-key').setup {
                delay = 500, -- Show popup after 500ms
            }
        end,
    },

    -- Harpoon - Fast file navigation
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- Undotree - Visual undo history
    'mbbill/undotree',

    -- Trouble - Better diagnostic list
    {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('trouble').setup {}
        end,
    },

    -- Flash - Enhanced motion
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        opts = {},
    },

    -- Mini.surround - Surround operations
    {
        'echasnovski/mini.surround',
        version = '*',
        config = function()
            require('mini.surround').setup()
        end,
    },

    -- Colorizer - Show colors inline
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end,
    },

    -- Indent-blankline - Indentation guides
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function()
            require('ibl').setup {
                enabled = false,
                indent = { char = '│' },
                scope = { enabled = false },
            }
        end,
    },

    -- UFO - Better code folding
    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            vim.o.foldcolumn = '1'
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            require('ufo').setup()
        end,
    },

    -- Todo-comments - Highlight TODO/FIXME/etc
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('todo-comments').setup {}
        end,
    },

    -- Persistence - Session management
    {
        'folke/persistence.nvim',
        event = 'BufReadPre',
        config = function()
            require('persistence').setup {
                dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/'),
                options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
            }
        end,
    },

    -- Neogit - Git integration
    {
        'NeogitOrg/neogit',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('neogit').setup {}
        end,
    },

    -- Dressing - Better UI for inputs
    {
        'stevearc/dressing.nvim',
        opts = {},
    },

    -- Hydra - Modal command sequences
    {
        'anuvyklack/hydra.nvim',
        event = 'VeryLazy',
    },

    -- Noice - Redesigned UI
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
        },
        config = function()
            require('noice').setup {
                lsp = {
                    override = {
                        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                        ['vim.lsp.util.stylize_markdown'] = true,
                        ['cmp.entry.get_documentation'] = true,
                    },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = false,
                },
            }
        end,
    },

    -- Markdown preview
    {
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        ft = { 'markdown' },
        build = 'cd app && npx --yes yarn install',
    },

    -- Markdown rendering (Obsidian-like read mode)
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown' },
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {},
    },

    -- CSV viewer
    {
        'hat0uma/csvview.nvim',
        ft = { 'csv' },
        opts = {
            view = {
                display_mode = 'border',
            },
        },
    },

    -- Markdown checkbox management
    {
        'bullets-vim/bullets.vim',
        ft = { 'markdown', 'text' },
        config = function()
            vim.g.bullets_enabled_file_types = { 'markdown', 'text' }
            vim.g.bullets_checkbox_markers = ' .oOX'
        end,
    },

    -- Cellular-automaton (fun animations)
    {
        'eandrju/cellular-automaton.nvim',
        cmd = 'CellularAutomaton',
    },

    -- Zen mode (distraction-free coding)
    {
        'folke/zen-mode.nvim',
        cmd = 'ZenMode',
        opts = {
            window = {
                width = 120,
                options = {
                    number = false,
                    relativenumber = false,
                },
            },
        },
    },

    -- Twilight (dims inactive code)
    {
        'folke/twilight.nvim',
        cmd = 'Twilight',
        opts = {},
    },

    -- Substitute (better substitute operations)
    {
        'gbprod/substitute.nvim',
        event = 'VeryLazy',
        config = function()
            require('substitute').setup()
        end,
    },

    -- hlslens (better search highlighting)
    {
        'kevinhwang91/nvim-hlslens',
        event = 'VeryLazy',
        config = function()
            require('hlslens').setup()
        end,
    },

    -- Theme
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup {
                flavour = 'mocha',
                transparent_background = false,
                term_colors = true,
                styles = {
                    comments = { 'italic' },
                    functions = { 'bold' },
                    keywords = { 'italic' },
                    strings = {},
                    variables = {},
                },
                color_overrides = {},
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    treesitter = true,
                    telescope = true,
                },
            }
        end,
    },
    {
        "vague-theme/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require('vague').setup {}
            vim.cmd 'colorscheme vague'

            -- Softer editing surface: keep the theme, reduce noisy highlights.
            vim.api.nvim_set_hl(0, 'CursorLine', { bg = 'NONE' })
            vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#C8CBE0', bold = true })
            vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#2C2E3E', bg = 'NONE' })
            vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#1A1B26' })
            vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#171824' })
            vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#3A3D52', bg = '#171824' })
        end
    },

    -- Additional themes (switch with Space th)
    {
        'folke/tokyonight.nvim',
        lazy = true,
        opts = {
            transparent = false,
            style = 'night',
        },
    },
    {
        'EdenEast/nightfox.nvim',
        lazy = true,
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = true,
    },
}

-- =========================================================
-- Theme
-- =========================================================
-- vim.cmd.colorscheme 'catppuccin-mocha' -- commented out, using vague theme instead

-- =========================================================
-- Plugin Configs
-- =========================================================

-- Lualine
require('lualine').setup {
    options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
    },
}

-- Comment
require('Comment').setup()

-- Gitsigns
require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
}

-- Oil.nvim (file explorer as a buffer)
require('oil').setup {
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ['<C-h>'] = false,
        ['<C-l>'] = false,
    },
}

-- =========================================================
-- Mason + LSP Setup
-- =========================================================
require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = {
        'lua_ls',        -- Lua
        'ts_ls',         -- TypeScript/JavaScript
        'html',          -- HTML
        'cssls',         -- CSS
        'jsonls',        -- JSON
        'tailwindcss',   -- Tailwind CSS
        'eslint',        -- ESLint
        'prismals',      -- Prisma
        'gopls',         -- Go
        'rust_analyzer', -- Rust
        'pyright',       -- Python
    },
}

require('mason-tool-installer').setup {
    ensure_installed = {
        'rust-analyzer',
        'codelldb',
    },
    auto_update = false,
    run_on_start = true,
    start_delay = 3000,
}

require('mason-nvim-dap').setup {
    ensure_installed = { 'codelldb' },
    automatic_installation = true,
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup keybindings when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, 'Goto Definition')
        map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
        map('gi', vim.lsp.buf.implementation, 'Goto Implementation')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        map('gr', vim.lsp.buf.references, 'Goto References')
        map('<leader>d', vim.diagnostic.open_float, 'Show Diagnostics')
        map('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
        map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')
    end,
})

-- TypeScript/JavaScript LSP
vim.lsp.config.ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json' },
    capabilities = capabilities,
}

-- HTML LSP
vim.lsp.config.html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    root_markers = { 'package.json' },
    capabilities = capabilities,
}

-- CSS LSP
vim.lsp.config.cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    root_markers = { 'package.json' },
    capabilities = capabilities,
}

-- JSON LSP
vim.lsp.config.jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    root_markers = { 'package.json' },
    capabilities = capabilities,
}

-- Tailwind CSS LSP
vim.lsp.config.tailwindcss = {
    cmd = { 'tailwindcss-language-server', '--stdio' },
    root_markers = { 'tailwind.config.js', 'tailwind.config.ts' },
    capabilities = capabilities,
}

-- ESLint LSP
vim.lsp.config.eslint = {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'package.json' },
    capabilities = capabilities,
}

-- Prisma LSP
vim.lsp.config.prismals = {
    cmd = { 'prisma-language-server', '--stdio' },
    root_markers = { 'schema.prisma' },
    capabilities = capabilities,
}

-- Python LSP
vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt' },
    capabilities = capabilities,
}

-- Go LSP
vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    root_markers = { 'go.mod', 'go.work' },
    capabilities = capabilities,
}

-- Lua LSP
vim.lsp.config.lua_ls = {
    cmd = { 'lua-language-server' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml' },
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
}

-- Enable all configured LSP servers
vim.lsp.enable {
    'ts_ls',
    'html',
    'cssls',
    'jsonls',
    'tailwindcss',
    'eslint',
    'prismals',
    'pyright',
    'gopls',
    'lua_ls',
}

-- =========================================================
-- Completion (nvim-cmp)
-- =========================================================
local cmp = require 'cmp'
local luasnip = require 'luasnip'

-- Load friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<Tab>'] = cmp.mapping(function(fallback)
            if vim.fn.exists('*copilot#Visible') == 1 and vim.fn['copilot#Visible']() == 1 then
                vim.api.nvim_feedkeys(vim.fn['copilot#Accept']('<CR>'), 'i', true)
            elseif cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    }),
}

-- =========================================================
-- Formatter (conform.nvim)
-- =========================================================
require('conform').setup {
    formatters_by_ft = {
        -- Lua
        lua = { 'stylua' },

        -- JavaScript/TypeScript
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },

        -- Web
        html = { 'prettier' },
        css = { 'prettier' },
        json = { 'prettier' },
        markdown = { 'prettier' },

        -- Python
        python = { 'black', 'isort' },

        -- Go
        go = { 'gofmt', 'goimports' },

        -- Rust
        rust = { 'rustfmt' },

        -- SQL
        sql = { 'sql_formatter' },

        -- Java
        java = { 'google-java-format', 'lsp' },
    },
    formatters = {
        isort = {
            prepend_args = { '--profile', 'black' },
        },
    },
    format_on_save = {
        timeout_ms = 5000,
        lsp_fallback = true,
    },
}

-- =========================================================
-- GitHub Copilot Keymaps
-- =========================================================
vim.keymap.set('i', '<C-l>', 'copilot#Accept("<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = 'Copilot: Accept suggestion (reliable)',
})

vim.keymap.set('i', '<M-l>', 'copilot#Accept("<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = 'Copilot: Accept suggestion',
})
vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'Copilot: Next suggestion' })
vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', { desc = 'Copilot: Previous suggestion' })
vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)', { desc = 'Copilot: Dismiss suggestion' })

local function open_copilot_chat_right()
    local function set_copilot_chat_cwd()
        local bufname = vim.api.nvim_buf_get_name(0)
        local start = (bufname ~= '' and vim.fs.dirname(bufname)) or vim.fn.getcwd()
        local git_dir = vim.fs.find('.git', { path = start, upward = true })[1]
        local root = git_dir and vim.fs.dirname(git_dir) or vim.fn.getcwd()
        pcall(vim.cmd, 'lcd ' .. vim.fn.fnameescape(root))
    end

    set_copilot_chat_cwd()
    local old_splitright = vim.o.splitright
    vim.o.splitright = true
    pcall(vim.cmd, 'CopilotChat')
    vim.o.splitright = old_splitright
end

vim.keymap.set('n', '<leader>cc', open_copilot_chat_right, { desc = 'Copilot Chat (right split)' })
vim.keymap.set('n', '<leader>cR', '<cmd>CopilotChatReset<CR>', { desc = 'Copilot Chat: Reset' })

local function copilot_chat_save_prompt()
    local name = vim.fn.input 'Save Copilot chat as: '
    if name ~= nil and name ~= '' then
        vim.cmd('CopilotChatSave ' .. vim.fn.fnameescape(name))
    end
end

-- =========================================================
-- Session Persistence Keymaps
-- =========================================================
local function cleanup_stale_copilot_chat_buffers()
    -- Session files can resurrect a plain buffer named "copilot-chat".
    -- CopilotChat then fails with E95 when creating its managed overlay buffer.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ok_name, name = pcall(vim.api.nvim_buf_get_name, buf)
        if ok_name and name ~= nil and name:match('copilot%-chat$') then
            pcall(vim.cmd, 'silent! bwipeout! ' .. buf)
        end
    end
end

-- Preserve window/tab sizes and terminals when saving sessions.
vim.opt.sessionoptions = {
    'blank',
    'buffers',
    'curdir',
    'folds',
    'help',
    'tabpages',
    'winsize',
    'terminal',
    'localoptions',
}

vim.keymap.set('n', '<leader>ss', function()
    local name = vim.fn.input('Save session as: ')
    if name ~= '' and name ~= nil then
        -- Ensure directory exists
        local session_dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/')
        vim.fn.mkdir(session_dir, 'p')

        -- Save with custom name
        local session_file = session_dir .. name .. '.vim'
        vim.cmd('mksession! ' .. vim.fn.fnameescape(session_file))

        -- Save exact current split sizes (mksession tends to equalize on load).
        local sizes_file = session_dir .. name .. '.sizes.vim'
        local sizes_cmd = vim.fn.winrestcmd()
        local lines = {
            '" Auto-generated: exact split sizes for session ' .. name,
            'silent! execute ' .. vim.fn.string(sizes_cmd),
        }
        vim.fn.writefile(lines, sizes_file)

        vim.notify('Session saved: ' .. name, vim.log.levels.INFO)
    end
end, { desc = 'Save session (layout, buffers, CopilotChat, terminals)' })

vim.keymap.set('n', '<leader>sl', function()
    require('persistence').load()
    vim.notify('Session loaded!', vim.log.levels.INFO)
end, { desc = 'Load last session' })

vim.keymap.set('n', '<leader>sL', function()
    require('persistence').load { last = true }
    vim.notify('Loaded last session!', vim.log.levels.INFO)
end, { desc = 'Load last session (last directory)' })

-- Session picker with Telescope
vim.keymap.set('n', '<leader>sD', function()
    local session_dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/')

    -- List only real session files (*.vim), excluding helper sidecars (*.sizes.vim).
    local files = vim.fn.glob(session_dir .. '*.vim', false, true)
    local sessions = {}
    for _, path in ipairs(files) do
        local base = vim.fn.fnamemodify(path, ':t')
        if not base:match('%.sizes%.vim$') then
            local name = base:gsub('%.vim$', '')
            table.insert(sessions, name)
        end
    end

    table.sort(sessions, function(a, b)
        return a:lower() < b:lower()
    end)

    if #sessions == 0 then
        vim.notify('No sessions found. Save one with <leader>ss', vim.log.levels.WARN)
        return
    end

    local pickers = require 'telescope.pickers'
    local conf = require('telescope.config').values
    local action_state = require 'telescope.actions.state'
    local actions = require 'telescope.actions'

    pickers.new({}, {
        prompt_title = 'Load Session',
        finder = require('telescope.finders').new_table { results = sessions },
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local session_file = session_dir .. selection.value .. '.vim'
                    local sizes_file = session_dir .. selection.value .. '.sizes.vim'
                    local legacy_sizes_file = session_file .. '.sizes.vim'

                    -- If there are unsaved changes, ask before replacing the workspace.
                    local modified = vim.fn.getbufinfo { bufmodified = 1 }
                    if #modified > 0 then
                        local answer = vim.fn.confirm(
                            'Discard unsaved buffers and load session "' .. selection.value .. '"?', '&Yes\n&No', 2)
                        if answer ~= 1 then
                            return
                        end
                    end

                    -- Fully clear current UI/buffers so mksession can restore exact layout and sizing.
                    vim.cmd 'silent! wall'
                    vim.cmd 'silent! tabonly!'
                    vim.cmd 'silent! %bwipeout!'
                    vim.cmd('silent! source ' .. vim.fn.fnameescape(session_file))

                    -- Reapply exact split dimensions captured during save.
                    if vim.fn.filereadable(sizes_file) == 1 then
                        vim.cmd('silent! source ' .. vim.fn.fnameescape(sizes_file))
                    elseif vim.fn.filereadable(legacy_sizes_file) == 1 then
                        vim.cmd('silent! source ' .. vim.fn.fnameescape(legacy_sizes_file))
                    end

                    cleanup_stale_copilot_chat_buffers()

                    vim.notify('Loaded session: ' .. selection.value, vim.log.levels.INFO)
                end
            end)
            return true
        end,
    }):find()
end, { desc = 'Load saved session' })

vim.keymap.set('n', '<leader>sx', function()
    local session_dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/')
    local files = vim.fn.glob(session_dir .. '*.vim', false, true)
    local sessions = {}

    for _, path in ipairs(files) do
        local base = vim.fn.fnamemodify(path, ':t')
        if not base:match('%.sizes%.vim$') then
            local name = base:gsub('%.vim$', '')
            table.insert(sessions, name)
        end
    end

    if #sessions == 0 then
        vim.notify('No sessions to delete', vim.log.levels.WARN)
        return
    end

    table.sort(sessions, function(a, b)
        return a:lower() < b:lower()
    end)

    local pickers = require 'telescope.pickers'
    local conf = require('telescope.config').values
    local action_state = require 'telescope.actions.state'
    local actions = require 'telescope.actions'

    pickers.new({}, {
        prompt_title = 'Delete Session',
        finder = require('telescope.finders').new_table { results = sessions },
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection then
                    return
                end

                local name = selection.value
                local answer = vim.fn.confirm('Delete session "' .. name .. '"?', '&Yes\n&No', 2)
                if answer == 1 then
                    local session_file = session_dir .. name .. '.vim'
                    local sizes_file = session_dir .. name .. '.sizes.vim'
                    local legacy_sizes_file = session_file .. '.sizes.vim'

                    local ok_session, err_session = os.remove(session_file)
                    -- Best-effort cleanup for both helper naming schemes.
                    pcall(os.remove, sizes_file)
                    pcall(os.remove, legacy_sizes_file)

                    if ok_session then
                        vim.notify('Deleted session: ' .. name, vim.log.levels.INFO)
                    else
                        vim.notify('Failed to delete session: ' .. tostring(err_session), vim.log.levels.ERROR)
                    end
                end
            end)
            return true
        end,
    }):find()
end, { desc = 'Delete saved session' })

-- CopilotChat session browser with Telescope
local function open_and_load_copilot_chat(name)
    cleanup_stale_copilot_chat_buffers()
    pcall(vim.cmd, 'silent! CopilotChatClose')
    vim.schedule(function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local start = (bufname ~= '' and vim.fs.dirname(bufname)) or vim.fn.getcwd()
        local git_dir = vim.fs.find('.git', { path = start, upward = true })[1]
        local root = git_dir and vim.fs.dirname(git_dir) or vim.fn.getcwd()
        pcall(vim.cmd, 'lcd ' .. vim.fn.fnameescape(root))

        cleanup_stale_copilot_chat_buffers()
        pcall(vim.cmd, 'CopilotChatLoad ' .. vim.fn.fnameescape(name))
        open_copilot_chat_right()
    end)
end

vim.keymap.set('n', '<leader>cL', function()
    local chat_dir = vim.fn.expand '~/.local/share/nvim/copilotchat_history/'

    -- Build chat list from JSON files in history dir (no shell parsing)
    local chats = {}
    local files = vim.fn.glob(chat_dir .. '*.json', false, true)
    for _, path in ipairs(files) do
        local name = vim.fn.fnamemodify(path, ':t:r')
        if name ~= nil and name ~= '' then
            table.insert(chats, name)
        end
    end

    table.sort(chats, function(a, b)
        return a:lower() < b:lower()
    end)

    if #chats == 0 then
        vim.notify('No Copilot Chat sessions found. Create one with :CopilotChatSave', vim.log.levels.WARN)
        return
    end

    local pickers = require 'telescope.pickers'
    local conf = require('telescope.config').values
    local action_state = require 'telescope.actions.state'
    local actions = require 'telescope.actions'

    pickers.new({}, {
        prompt_title = 'Load Copilot Chat',
        finder = require('telescope.finders').new_table { results = chats },
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    open_and_load_copilot_chat(selection.value)
                end
            end)
            return true
        end,
    }):find()
end, { desc = 'Load Copilot Chat session (Telescope browser)' })
vim.keymap.set('n', '<leader>cl', '<leader>cL',
    { remap = true, desc = 'Load Copilot Chat session (Telescope browser alias)' })

vim.keymap.set('n', '<leader>cx', function()
    local chat_dir = vim.fn.expand '~/.local/share/nvim/copilotchat_history/'
    local files = vim.fn.glob(chat_dir .. '*.json', false, true)
    local chats = {}

    for _, path in ipairs(files) do
        local name = vim.fn.fnamemodify(path, ':t:r')
        if name ~= '' then
            table.insert(chats, name)
        end
    end

    if #chats == 0 then
        vim.notify('No Copilot Chat sessions to delete', vim.log.levels.WARN)
        return
    end

    table.sort(chats, function(a, b)
        return a:lower() < b:lower()
    end)

    local pickers = require 'telescope.pickers'
    local conf = require('telescope.config').values
    local action_state = require 'telescope.actions.state'
    local actions = require 'telescope.actions'

    pickers.new({}, {
        prompt_title = 'Delete Copilot Chat Session',
        finder = require('telescope.finders').new_table { results = chats },
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection then
                    return
                end

                local name = selection.value
                local answer = vim.fn.confirm('Delete Copilot chat "' .. name .. '"?', '&Yes\n&No', 2)
                if answer == 1 then
                    local chat_file = chat_dir .. name .. '.json'
                    local ok, err = os.remove(chat_file)
                    if ok then
                        vim.notify('Deleted Copilot chat: ' .. name, vim.log.levels.INFO)
                    else
                        vim.notify('Failed to delete Copilot chat: ' .. tostring(err), vim.log.levels.ERROR)
                    end
                end
            end)
            return true
        end,
    }):find()
end, { desc = 'Delete Copilot Chat session' })

local function copilot_chat_load_prompt()
    local name = vim.fn.input 'Load Copilot chat: '
    if name ~= nil and name ~= '' then
        open_and_load_copilot_chat(name)
    end
end

vim.keymap.set('n', '<leader>cs', copilot_chat_save_prompt, { desc = 'Copilot Chat: Save named session' })
vim.keymap.set('n', '<leader>cn', copilot_chat_load_prompt, { desc = 'Copilot Chat: Load named session' })

vim.keymap.set('v', '<leader>ce', '<cmd>CopilotChatExplain<CR>', { desc = 'Copilot Chat: Explain selection' })
vim.keymap.set('v', '<leader>cf', '<cmd>CopilotChatFix<CR>', { desc = 'Copilot Chat: Fix selection' })

-- Manual format keymap
vim.keymap.set('n', '<leader>f', function()
    require('conform').format { async = true, lsp_fallback = true }
end, { desc = 'Format file' })

-- Overseer keymaps (task runner)
vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = 'Overseer: Run task' })
vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<CR>', { desc = 'Overseer: Toggle task list' })
vim.keymap.set('n', '<leader>oa', '<cmd>OverseerQuickAction<CR>', { desc = 'Overseer: Task quick actions' })
vim.keymap.set('n', '<leader>oi', '<cmd>OverseerInfo<CR>', { desc = 'Overseer: Diagnostics/info' })

-- =========================================================
-- Telescope Keymaps
-- =========================================================
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', function()
    builtin.find_files { cwd = vim.fn.getcwd() }
end, { desc = 'Find files (current directory)' })
vim.keymap.set('n', '<leader>fg', function()
    builtin.live_grep { cwd = vim.fn.getcwd() }
end, { desc = 'Live grep (current directory)' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Recent files' })

-- =========================================================
-- Search (hlslens) Keymaps
-- =========================================================
vim.keymap.set('n', 'n', function()
    vim.cmd('normal! ' .. vim.v.count1 .. 'n')
    local ok, lens = pcall(require, 'hlslens')
    if ok and lens.start then
        lens.start()
    end
end, { desc = 'Next search result' })
vim.keymap.set('n', 'N', function()
    vim.cmd('normal! ' .. vim.v.count1 .. 'N')
    local ok, lens = pcall(require, 'hlslens')
    if ok and lens.start then
        lens.start()
    end
end, { desc = 'Previous search result' })

-- =========================================================
-- Harpoon Keymaps
-- =========================================================
local harpoon = require 'harpoon'
harpoon:setup()

vim.keymap.set('n', '<leader>a', function()
    harpoon:list():add()
end, { desc = 'Harpoon: Add file' })
vim.keymap.set('n', '<C-e>', function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon: Toggle menu' })

vim.keymap.set('n', '<C-1>', function()
    harpoon:list():select(1)
end, { desc = 'Harpoon: Go to file 1' })
vim.keymap.set('n', '<C-2>', function()
    harpoon:list():select(2)
end, { desc = 'Harpoon: Go to file 2' })
vim.keymap.set('n', '<C-3>', function()
    harpoon:list():select(3)
end, { desc = 'Harpoon: Go to file 3' })
vim.keymap.set('n', '<C-4>', function()
    harpoon:list():select(4)
end, { desc = 'Harpoon: Go to file 4' })

-- =========================================================
-- Undotree Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle Undotree' })

-- =========================================================
-- Trouble Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Trouble: Diagnostics' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    { desc = 'Trouble: Buffer Diagnostics' })
vim.keymap.set('n', '<leader>ts', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Trouble: Symbols' })
vim.keymap.set('n', '<leader>tl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'Trouble: LSP' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Trouble: Location List' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Trouble: Quickfix List' })

-- =========================================================
-- Flash Keymaps
-- =========================================================
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
    require('flash').jump()
end, { desc = 'Flash: Jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
    require('flash').treesitter()
end, { desc = 'Flash: Treesitter' })
vim.keymap.set('o', 'r', function()
    require('flash').remote()
end, { desc = 'Flash: Remote' })
vim.keymap.set({ 'o', 'x' }, 'R', function()
    require('flash').treesitter_search()
end, { desc = 'Flash: Treesitter Search' })

-- =========================================================
-- Todo-comments Keymaps
-- =========================================================
vim.keymap.set('n', ']t', function()
    require('todo-comments').jump_next()
end, { desc = 'Next todo comment' })
vim.keymap.set('n', '[t', function()
    require('todo-comments').jump_prev()
end, { desc = 'Previous todo comment' })
vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = 'Find Todo comments' })

-- =========================================================
-- Persistence Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>qs', function()
    require('persistence').load()
end, { desc = 'Restore Session' })
vim.keymap.set('n', '<leader>ql', function()
    require('persistence').load { last = true }
end, { desc = 'Restore Last Session' })
vim.keymap.set('n', '<leader>qd', function()
    require('persistence').stop()
end, { desc = "Don't Save Session" })

-- =========================================================
-- Neogit Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'Open Neogit' })
vim.keymap.set('n', '<leader>gc', '<cmd>Neogit commit<cr>', { desc = 'Git Commit' })

-- =========================================================
-- Markdown Preview Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', { desc = 'Toggle Markdown Preview' })

-- Markdown read/write mode (Obsidian-like)
vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown toggle<cr>', { desc = 'Toggle Markdown read mode' })

-- =========================================================
-- Markdown Checkbox Toggle Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>mt', '<cmd>InsertNewBullet<cr>', { desc = 'Insert new markdown bullet' })
-- bullets.vim automatically provides <C-t> to toggle checkboxes in insert mode
-- and <leader>x to toggle in normal mode (customizable below)
vim.keymap.set('n', '<leader>mx', function()
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if line:match('%- %[ %]') then
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line:gsub('%- %[ %]', '- [x]') })
    elseif line:match('%- %[x%]') then
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line:gsub('%- %[x%]', '- [ ]') })
    elseif line:match('^%s*%-') then
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line:gsub('(^%s*%-)(.*)$', '%1 [ ]%2') })
    end
end, { desc = 'Toggle markdown checkbox' })

-- =========================================================
-- Cellular Automaton Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>mr', function()
    if vim.bo.filetype ~= 'oil' and vim.bo.filetype ~= 'netrw' then
        vim.cmd('CellularAutomaton make_it_rain')
    else
        vim.notify('CellularAutomaton: Works best in code buffers', vim.log.levels.INFO)
    end
end, { desc = 'Make it rain!' })

-- =========================================================
-- Zen Mode Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<cr>', { desc = 'Toggle Zen Mode' })

-- =========================================================
-- Substitute Keymaps
-- =========================================================
vim.keymap.set('n', 'gs', require('substitute').operator, { desc = 'Substitute' })
vim.keymap.set('n', 'gss', require('substitute').line, { desc = 'Substitute line' })
vim.keymap.set('n', 'gS', require('substitute').eol, { desc = 'Substitute to end of line' })
vim.keymap.set('x', 'gs', require('substitute').visual, { desc = 'Substitute visual' })

-- =========================================================
-- Colorscheme Switcher Keymap
-- =========================================================
vim.keymap.set('n', '<leader>th', '<cmd>Telescope colorscheme<cr>', { desc = 'Switch theme' })

-- CSV viewer toggle
vim.keymap.set('n', '<leader>cv', '<cmd>CsvViewToggle<cr>', { desc = 'Toggle CSV table view' })

-- =========================================================
-- General Keymaps
-- =========================================================
vim.keymap.set('n', '<leader>e', '<CMD>Oil<CR>', { desc = 'Open file explorer' })
vim.keymap.set('n', '<leader>w', '<CMD>w<CR>', { desc = 'Write (save)' })
vim.keymap.set('n', '<leader>c', '<CMD>bd<CR>', { desc = 'Close buffer (stay in nvim)' })
vim.keymap.set('n', '<leader>q', '<CMD>q<CR>', { desc = 'Quit nvim' })
vim.keymap.set('n', '<leader>wq', '<CMD>wq<CR>', { desc = 'Write and quit nvim' })
-- Prettify / format buffer
vim.keymap.set('n', '<leader>p', function()
    if vim.bo.filetype == 'rust' then
        pcall(require, 'conform').format({ buf = 0, async = false })
    else
        pcall(vim.lsp.buf.format, { timeout_ms = 3000 })
    end
end, { desc = 'Prettify / Format buffer' })

vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Terminal keymaps
vim.keymap.set('n', '<leader>tt', '<CMD>botright split | terminal<CR>', { desc = 'Terminal (horizontal)' })
vim.keymap.set('n', '<leader>tv', '<CMD>vsplit | terminal<CR>', { desc = 'Terminal (vertical)' })
vim.keymap.set('n', '<leader>tf', '<CMD>terminal<CR>', { desc = 'Terminal (fullscreen)' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window resizing with Hydra (modal: hold keys to keep resizing)
local Hydra = require 'hydra'
Hydra {
    name = 'Window Resize',
    mode = 'n',
    body = '<leader>r',
    heads = {
        { '<', '<cmd>vertical resize -2<CR>', { desc = 'decrease width' } },
        { '>', '<cmd>vertical resize +2<CR>', { desc = 'increase width' } },
        { '+', '<cmd>resize +2<CR>',          { desc = 'increase height' } },
        { '-', '<cmd>resize -2<CR>',          { desc = 'decrease height' } },
        { 'q', nil,                           { exit = true } },
    },
}

-- Allow capital 'R' to enter the same resize Hydra (user expectation: press R then + / -)
vim.keymap.set('n', 'R', '<leader>r', { desc = 'Enter Resize mode (Hydra)', noremap = true })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Move lines
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- =========================================================
-- Auto Commands
-- =========================================================
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
        local save_cursor = vim.fn.getpos '.'
        vim.cmd [[%s/\s\+$//e]]
        vim.fn.setpos('.', save_cursor)
    end,
})

-- Start terminal in insert mode
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = '*',
    callback = function()
        vim.cmd 'startinsert'
    end,
})
