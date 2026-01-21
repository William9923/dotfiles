# NEOVIM (SNORLAX.NVM) KNOWLEDGE BASE

LazyVim-based config with custom plugins. Gruvbox colorscheme.

## STRUCTURE

```
lua/
├── config/         # Core settings (keymaps, options, autocmds)
├── plugins/        # Plugin specs (one concern per file)
└── personal/       # Custom utilities (discipline.lua)
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Add plugin | `lua/plugins/{concern}.lua` - return spec table |
| Change keymap | `lua/config/keymaps.lua` or plugin `keys = {}` |
| Add LSP server | `lua/plugins/lsp.lua` → `opts.servers` |
| Add formatter | `lua/plugins/formatting.lua` → `formatters_by_ft` |
| Change UI | `lua/plugins/ui.lua` |
| Add autocmd | `lua/config/autocmds.lua` |

## CONVENTIONS

### Plugin Specs
```lua
return {
  {
    "author/plugin-name",
    event = "LazyFile",  -- lazy load
    opts = {},           -- merge with defaults
    config = function(_, opts)
      require("plugin").setup(opts)
    end,
  },
}
```

### Keymaps
```lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
keymap("n", "<leader>xx", "<cmd>Command<cr>", opts)
```

### Options
- `vim.opt.{option}` for Vim options
- `vim.g.{var}` for global variables
- `vim.g.lazyvim_*` for LazyVim-specific settings

### LSP Customization
- Disable default keymaps: `keys[#keys + 1] = { "<key>", false }`
- Add keymaps via `init` function in nvim-lspconfig spec
- Server config in `opts.servers.{server_name}`

## ANTI-PATTERNS

| Never | Do Instead |
|-------|------------|
| Edit lazy-lock.json manually | Let Lazy.nvim manage it |
| Put all plugins in one file | Split by concern (lsp.lua, ui.lua, etc.) |
| Use deprecated `require("lazyvim.util").lsp` | Check LazyVim docs for current API |
| Hardcode paths | Use `vim.fn.stdpath()` |

## KEY CUSTOMIZATIONS

- `<Space>` = leader
- `kk` = escape (insert mode)
- `gh` = LSP references
- `<leader>la` = code action
- `<leader>lr` = rename (inc-rename)
- `<leader>ff` = format
- `<C-h/j/k/l>` = tmux-aware navigation
- `;t` = todo comments search

## LSP SERVERS

Configured: lua_ls, yamlls, vtsls (with Vue), gopls

Mason ensures: stylua, luacheck, shellcheck, shfmt, goimports, vue-language-server

## NOTES

- Picker: fzf (`vim.g.lazyvim_picker = "fzf"`)
- Autoformat disabled by default (`vim.g.autoformat = false`)
- Treesitter folding enabled with persistent folds
- Animations disabled (`vim.g.snacks_animate = false`)
