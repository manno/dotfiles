# Neovim Configuration

## 🎯 Philosophy

- **Native LSP Integration**: Uses `vim.lsp.enable()` instead of traditional lspconfig setup
- **Capability-Driven Features**: Auto-enable features based on server capabilities
- **Multiple AI Backends**: Easy switching between GitHub Copilot, local LLMs, and vanilla completion
- **Minimal Dependencies**: Maximum functionality with clean architecture
- **Developer-Focused**: Excellent Git integration, file management, and language support

## 🏗️ Architecture

```
~/.config/nvim/
├── init.lua                    # Core settings & keybindings
├── lua/
│   ├── lsp.lua                # Native LSP setup & capabilities
│   ├── plugins.lua            # Plugin definitions (Lazy.nvim)
│   └── plugins/
│       ├── completion.lua            # blink.cmp (default)
│       ├── completion-copilot.lua    # + GitHub Copilot
│       ├── completion-minuet.lua     # + Local LLM (Ollama)
│       ├── lsp-config.lua           # LSP server configurations
│       └── assistance.lua           # AI chat interface
└── wall.txt                   # Dashboard ASCII art
```

## ⚡ Modern LSP Architecture

### Native LSP Implementation
Uses **Neovim's native LSP** (0.11+) instead of traditional lspconfig:

```lua
vim.lsp.enable({
  "clangd", "gopls", "helm_ls", "html", "jsonls",
  "lua_ls", "pylsp", "solargraph", "ts_ls", "yamlls"
})
```

**Benefits:**
- Decoupled server management from configuration
- Capability-driven feature activation
- Native Neovim integration
- Future-proof architecture

### Dynamic Features
- **Inlay Hints**: Auto-enabled per server capability
- **Document Highlighting**: Smart symbol highlighting
- **Go Integration**: Auto-import organization + formatting on save
- **Buffer-Local Keymaps**: Context-aware mappings

## 🔌 Plugin Ecosystem

### Core Plugins
- **lazy.nvim**: Modern plugin manager with lazy loading
- **nvim-treesitter**: Syntax highlighting & code navigation
- **blink.cmp**: Fast completion engine with multiple backends
- **snacks.nvim**: File picker, explorer, dashboard
- **lualine.nvim**: Customized status line
- **tokyonight.nvim**: Primary colorscheme

### Language Support
| Language | Server | Features |
|----------|--------|----------|
| Go | `gopls` | Auto-imports, formatting, inlay hints |
| C/C++ | `clangd` | IntelliSense, diagnostics |
| Python | `pylsp` | Linting, formatting, completion |
| TypeScript | `ts_ls` | Type checking, refactoring |
| Lua | `lua_ls` | Neovim API awareness |
| Ruby | `solargraph` | Diagnostics, completion |
| YAML | `yamlls` | Schema validation |
| HTML/JSON | Native | Built-in language servers |

## 🤖 AI Integration (3 Options)

### 1. Vanilla Setup (`completion.lua`)
Pure LSP completion with path, buffer, and snippets.

### 2. GitHub Copilot (`completion-copilot.lua`)
```bash
# Enable Copilot
export NVIM_COMPLETION=copilot
```

### 3. Local LLM (`completion-minuet.lua`)
```bash
# Start Ollama with qwen2.5-coder
ollama serve
ollama pull qwen2.5-coder:7b

# Enable local LLM
export NVIM_COMPLETION=minuet
```

### AI Chat Interface (Optional)
CodeCompanion provides chat interface with multiple providers. Enable with:
```bash
export NVIM_ASSISTANCE=true
nvim
```

**Supported providers:**
- **Gemini**: Google's LLM
- **GitHub Copilot**: Chat API  
- **Ollama**: Local models

**Disabled by default** to keep the configuration lightweight.

## ⌨️ Key Bindings

### File Operations
| Key | Action | Description |
|-----|--------|-------------|
| `<leader><space>` | Smart Find | Context-aware file finder |
| `<leader>e` | Explorer | Built-in file tree |
| `<leader>ge` | Reveal | Reveal current file in explorer |
| `<leader>t` | Git Files | Find files in repository |
| `<leader>ff` | Find Files | Find all files |
| `<leader>fg` | Git Files | Find files in git repository |
| `<leader>fr` | Recent | Recently opened files |
| `<leader>fc` | Config Files | Find Neovim config files |
| `<leader>fp` | Projects | Project picker |

### Search & Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>f` | Grep | Search text in files |
| `<leader>g` | Grep Word | Search current word/selection |
| `<leader>G` | Git Grep | Search with git grep |
| `<leader>gw` | Grep Word | Search word under cursor |
| `<leader>b` | Buffers | Switch buffers |
| `<leader>sb` | Buffer Lines | Search lines in current buffer |
| `<leader>sB` | Grep Buffers | Grep open buffers |
| `<leader>s"` | Registers | Show registers |
| `<leader>s/` | Search History | Search command history |
| `<leader>:` | Command History | Command history picker |

### Advanced Search & Symbols
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>sa` | Autocmds | Show autocommands |
| `<leader>sc` | Command History | Command history |
| `<leader>sC` | Commands | Available commands |
| `<leader>sd` | Diagnostics | Project diagnostics |
| `<leader>sD` | Buffer Diagnostics | Current buffer diagnostics |
| `<leader>sh` | Help Pages | Vim help pages |
| `<leader>sH` | Highlights | Highlight groups |
| `<leader>si` | Icons | Nerd font icons |
| `<leader>sj` | Jumps | Jump list |
| `<leader>sk` | Keymaps | Key mappings |
| `<leader>sl` | Location List | Location list |
| `<leader>sm` | Marks | Show marks |
| `<leader>sM` | Man Pages | Manual pages |
| `<leader>sp` | Plugin Specs | Search plugin specs |
| `<leader>sq` | Quickfix | Quickfix list |
| `<leader>sR` | Resume | Resume last picker |
| `<leader>su` | Undo History | Undo tree |
| `<leader>uC` | Colorschemes | Switch colorschemes |
| `<leader>sn` | Notifications | Notification history |

### LSP Features
| Key | Action | Description |
|-----|--------|-------------|
| `K` | Hover | Show documentation |
| `gd` | Definition | Jump to definition |
| `<C-]>` | Definition | Alternative go to definition |
| `gr` | References | Find all references |
| `gi` | Implementation | Go to implementation |
| `gO` | Document Symbols | Show document symbols |
| `<leader>rn` | Rename | Rename symbol |
| `<space>a` | Code Actions | Show available actions |
| `]g` / `[g` | Diagnostics | Next/previous diagnostic |
| `<C-S>` | Signature Help | Function signature (insert mode) |

### Git Integration
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>v` | Diff View | Toggle git diff view |
| `<leader>gs` | Git Status | Git status picker |
| `<leader>gb` | Git Branches | Switch branches |
| `<leader>gl` | Git Log | View git log |
| `<leader>gL` | Git Log Line | Git log for current line |
| `<leader>gd` | Git Diff | View git diff hunks |
| `<leader>gf` | Git Log File | Git log for current file |
| `<leader>gS` | Git Stash | Git stash picker |

### Buffer & Window Management
| Key | Action | Description |
|-----|--------|-------------|
| `<C-n>` / `<C-p>` | Buffer Nav | Next/previous buffer |
| `<leader>w` | Close Buffer | Close current buffer (barbar) |
| `<leader>W` | Close Window | Close current window |
| `<leader>D` | Close All Buffers | Close all buffers |
| `<A-h/j/k/l>` | Window Nav | Move between windows |
| `<leader>n` / `<leader>p` | Tab Nav | Next/previous tab |

### Terminal & System
| Key | Action | Description |
|-----|--------|-------------|
| `<A-h/j/k/l>` | Terminal Nav | Terminal window navigation |
| `<F5>` | Toggle Paste | Toggle paste mode |
| `<F8>` | Spell Check | Enable spell check (en,de) |
| `<S-F8>` | German Spell | Enable German spell check |
| `<Esc><F8>` | Disable Spell | Disable spell checking |
| `<F2>` | Edit Config | Quick edit config files |
| `<F6>` | Command Mode | Enter command mode |
| `!ma` | Make | Compile current file |

### Text Manipulation & Surround
| Key | Action | Description |
|-----|--------|-------------|
| `sa` | Add Surround | Add surrounding chars (mini.surround) |
| `sr` | Replace Surround | Replace surrounding chars |
| `sd` | Delete Surround | Delete surrounding chars |
| `Y` | Yank to End | Yank to end of line (commented) |
| `J/K` | Move Lines | Move selected lines up/down (commented) |

### Development & Formatting
| Key | Action | Description |
|-----|--------|-------------|
| `:Wsudo` | Write as Root | Save file with sudo |
| `:Tidy` | HTML Tidy | Format HTML with tidy |
| `:FormatJSON` | Format JSON | Pretty-print JSON selection |
| `_th` | To HTML | Convert syntax to HTML |
| `_tt` | To TeX | Convert syntax to colored TeX |
| `_ta` | To ANSI | Convert selection to ANSI colors |

## 🌟 Advanced Features

### Dashboard
- Recent files with quick access
- Git status display (in git repos)
- Project picker integration
- Custom ASCII art display

### Development Tools
- **Persistent undo** with unlimited history
- **Auto-backup** system
- **Session management**
- **Word processor mode** for prose
- **Format-on-save** per language
- **Jump to last position** on file open

### Language-Specific
- **Go**: Auto-organize imports, synchronous formatting
- **Multi-language**: Tailored indentation and folding
- **Spell checking**: English/German support
- **Encoding support**: CP437 for .nfo files

## 🚀 Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this configuration
git clone <your-repo> ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

### Requirements
- **Neovim 0.11+**
- **Node.js** (for some language servers)
- **Git** (for version control features)
- **ripgrep** (for fast searching)
- **Ollama** (optional, for local LLM)

### Language Server Installation
```bash
# Go
go install golang.org/x/tools/gopls@latest

# Python
pip install python-lsp-server

# Ruby
gem install solargraph

# TypeScript
npm install -g typescript-language-server typescript

# C/C++
# Install clangd via your package manager
```

## 📊 Performance

- **Lazy loading**: Plugins load on-demand
- **Native LSP**: Better performance than plugin wrappers
- **Optimized fuzzy matching**: Rust-based blink.cmp
- **Minimal startup time**: Core functionality loads first

## 🔧 Customization

### Switching Completion Backends

The configuration dynamically loads completion backends via the `NVIM_COMPLETION` environment variable, avoiding git commit conflicts:

```bash
# Vanilla completion (default)
nvim

# GitHub Copilot
NVIM_COMPLETION=copilot nvim

# Local LLM (Ollama)
NVIM_COMPLETION=minuet nvim

# Set permanently in your shell profile
export NVIM_COMPLETION=copilot  # or minuet
```

### Adding Language Servers

**Important**: Language servers must be installed manually on your system first.

```lua
-- 1. Install the language server (example for Rust)
-- cargo install rust-analyzer

-- 2. Add to lua/lsp.lua enable list:
vim.lsp.enable({
  "rust_analyzer",  -- Uses lspconfig's default configuration
  -- ... existing servers
})
```

**How it works:**
- `vim.lsp.enable()` uses default configurations from nvim-lspconfig
- No additional setup needed - server configs are automatically applied
- Supports all servers from [nvim-lspconfig server list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md)
