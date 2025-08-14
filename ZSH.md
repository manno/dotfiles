# Zsh Configuration Documentation

This document provides comprehensive documentation of the Zsh configuration structure, options, and features implemented in this dotfiles repository.

## Configuration Architecture

### Modular Loading System

The configuration uses a sophisticated modular loading system centered around the `load_zshd` function in `~/.zsh/func/load_zshd`:

```zsh
# Dynamically loads all .zsh files from ~/.zsh/
# Provides visual feedback during loading process
load_zshd () {
    for i ($HOME/$ddir/*.zsh(.,@)) {
        echo -en "${grey}$(basename $i .zsh)${col}"
        source $i 2> /dev/null
        # Shows ☑ for success, ☐ for failure
    }
}
```

**Benefits:**
- Visual loading feedback with colored status indicators
- Error isolation - failed modules don't break the entire config
- Easy to add/remove modules by simply adding/removing .zsh files
- Maintains loading order through file naming

### Platform-Specific Configuration

**Entry Point**: `~/.zshrc` uses chezmoi templating to conditionally load platform-specific configurations:

```zsh
{{- if and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "arm64") -}}
{{   include ".zshrc_m1" }}
{{- else -}}
{{   include ".zshrc_linux" }}
{{- end -}}
```

**Platform Differences**:
- **ARM64 Mac**: Prioritizes `/opt/homebrew` paths, includes `$HOME/.local/bin`
- **Linux/x86**: Uses traditional `/usr/local` paths, includes `$HOME/.local/bin`
- **Unified PATH Management**: Consolidated logic with proper deduplication

## Shell Options Configuration

### Core Zsh Options (`~/.zsh/options.zsh`)

| Option | Setting | Purpose |
|--------|---------|---------|
| `NOhup` | Enabled | Don't send HUP signal to jobs when shell exits |
| `extendedglob` | Enabled | Enable extended globbing patterns (#, ^, ~) |
| `NOcheckjobs` | Enabled | Don't warn about background jobs on exit |

**Note**: `globcomplete` was removed as it's default behavior in modern Zsh.

### History Configuration (`~/.zsh/history.zsh`)

**Advanced History Settings**:
```zsh
HISTSIZE=200000              # Large in-memory history
SAVEHIST=200000              # Large on-disk history
HISTFILE=~/.zsh_history      # Default history file
HISTFILE_OLD=~/.zsh_history.old  # Backup history file
```

**History Options**:
- `INC_APPEND_HISTORY`: Write commands immediately after execution
- `HIST_IGNORE_DUPS`: Ignore consecutive duplicate commands
- `EXTENDED_HISTORY`: Store timestamps with commands
- `HIST_EXPIRE_DUPS_FIRST`: Remove duplicates first when trimming history
- `HIST_FIND_NO_DUPS`: Don't show duplicates in history search
- `HIST_IGNORE_SPACE`: Ignore commands starting with space
- `HIST_NO_STORE`: Don't store `history` and `fc` commands

**Special Features**:
- Separate sudo history (`~/.zsh_history-sudo`)
- Perl-based timestamp conversion for history viewing (`hist0`, `hist1`)
- PATH management now consolidated in platform-specific files with proper deduplication

## Prompt System (`~/.zsh/prompt.zsh`)

### Main Prompt Components

**Left Prompt (PROMPT)**:
```zsh
cPre=$'%{$fg[black]%}%(1j.⚑ .)%{$reset_color%}'    # Job indicator
cPS1=$'%n%{$fg[magenta]%}@%{$reset_color%}%m%{$fg[magenta]%}:%{$reset_color%}%~%{$fg[magenta]%}%# %{$reset_color%}'
```
- Job count indicator with Unicode flag symbol
- Username@hostname in colored format
- Current directory path
- Privilege indicator (`%` for user, `#` for root)

**Right Prompt (RPROMPT)**:
```zsh
RPROMPT=$'${del}$(vcs_info_wrapper)$(kubectl_wrapper)%{$reset_color%}'
```

### VCS Integration

**Git Branch Display**:
- Shows current branch in brackets `[branch]`
- Displays action state during rebase/merge `[branch|action]`
- Color-coded: branch (green), brackets (magenta), actions (red)

### Context Information

**Kubernetes Context Display**:
```zsh
kubectl_wrapper () {
    kubectl_context=$(kubectl config current-context 2> /dev/null)
    k=${${kubectl_context#k3d-}//(#m)[aeiou]/}  # Remove vowels for brevity
    echo "%{$fg[green]%}[%{$fg[magenta]%}$k%{$fg[green]%}]%{$reset_color%}"
}
```

**Additional Context**:
- Chroot environment detection (`/etc/debian_chroot`)
- Terminal-specific prompt behavior (disabled in screen sessions)

## Completion System (`~/.zsh/completion.zsh`)

### Performance Optimizations

**Caching**:
```zsh
cachedir=$HOME/.zsh/cache/$UID
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $cachedir
```

### Advanced Completion Features

**Fuzzy Matching**:
```zsh
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' \
        max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
```

**SSH Host Completion**:
```zsh
hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
zstyle ':completion:*:hosts' hosts $hosts
```

**Process Completion**:
```zsh
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
```

**Git Integration**:
```zsh
_git_co() { _git_checkout }  # Enable completion for git aliases
_git_lg() { _git_log }
```

## Key Bindings (`~/.zsh/keys.zsh`)

### Modern Key Binding System

**Hybrid Approach** (Default: Modern, Optional: zkbd):

**Standard Key Bindings** (default):
```zsh
bindkey "^[[H" beginning-of-line      # Home
bindkey "^[[F" end-of-line            # End
bindkey "^[[3~" delete-char           # Delete
bindkey "^[[2~" overwrite-mode        # Insert
# xterm variants
bindkey "^[OH" beginning-of-line      # Home (xterm)
bindkey "^[OF" end-of-line            # End (xterm)
```

**ZKBD Integration** (optional via `ZSH_USE_ZKBD=1`):
```zsh
# Enable in .env.localhost:
export ZSH_USE_ZKBD=1
```

**Key Detection Priority** (when zkbd enabled):
1. `$TERM-${DISPLAY:t}`
2. `$TERM-$VENDOR-$OSTYPE`
3. `$TERM-$VENDOR`
4. `$TERM`

### Key Mappings

**Navigation**:
- `Ctrl+[[1;5C/D`: Word-level movement (Ctrl+Arrow)
- `Home/End`: Line beginning/end
- `Delete/Insert`: Character operations

**Editing**:
- `Space`: Magic space with history expansion
- `Tab`: Complete word
- `Ctrl+X Ctrl+E`: Edit command line in editor

## Alias System

### Global Aliases (`~/.zsh/aliases.zsh`)

**Pipeline Filters**:
```zsh
alias -g G='|grep -i'        # Case-insensitive grep
alias -g XXD='|xxd'          # Hex dump
alias -g L='|less'           # Pager
alias -g V='2>&1 > /tmp/stdin.$$; vi /tmp/stdin.$$'  # Edit output
```

**Glob Patterns**:
```zsh
alias -g glob_recent='**/*(om[1])'  # Most recently modified file
alias -g FILES='**/*(.)'            # All regular files recursively
```

**Time & Navigation**:
```zsh
alias -g TODAY=$(date +%Y%m%d)      # Current date
alias -g ...='../..'                # Parent directory shortcuts
alias -g ....='../../..'
```

### Command Aliases (`~/.alias`)

**Enhanced Tools**:
```zsh
qwhich lsd && alias ls='lsd --date "+%b %d %H:%M"'  # Modern ls replacement
qwhich rg && alias rg="rg --hidden --sort=path --glob '!.git'"  # ripgrep
qwhich nvim && alias vi=nvim && alias vim=nvim  # Neovim
```

**Development Tools**:
```zsh
alias g='git --no-pager'            # Git shorthand
alias nogo='":!*_test.go" ":!*fake*.go" ":!vendor/*"'  # Go exclusions
```

**System Utilities**:
```zsh
alias df='df -Th -x tmpfs -x usbfs'  # Enhanced disk usage
alias du='du -h'                     # Human-readable sizes
alias diff='diff --exclude ".svn" -up'  # Better diff defaults
```

### Platform-Specific Aliases

**Homebrew Management** (`~/.zsh/m1brew.zsh`):
- Platform-aware `brew` alias pointing to the correct Homebrew installation
- ARM64: `/opt/homebrew/bin/brew`
- x86_64: `/usr/local/bin/brew`

**SSH Management**:
```zsh
alias fixsshtmux="export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock"
alias fixsshlinux='export SSH_AUTH_SOCK=`ls -1tr /tmp/ssh-*/agent.* | tail -1`'
alias fixsshmac='export SSH_AUTH_SOCK=`ls -1tr /private/tmp/com.apple.launchd.*/Listeners`'
```

**Chezmoi Integration**:
```zsh
alias cmm='chezmoi merge'
alias cma='chezmoi add'
alias cme='chezmoi edit'
alias ce='chezmoi edit --apply'      # Edit and apply in one command
```

## Advanced Features

### Help System (`~/.zsh/help.zsh`)

**Built-in Documentation**:
- `help-aliases`: List all global aliases
- `help-glob`: Comprehensive glob pattern reference
- `help-history`: Event designator documentation
- `help-variable`: Parameter expansion reference
- `help-keys`: Command line editing keys
- `help-curl`: Useful web services

### Environment Extensions (`~/.zsh/ext.zsh`)

**Development Environment Setup**:
```zsh
# Go development
if [[ -d "$HOME/go/bin" ]]; then
    path=($HOME/go/bin "$path[@]")
fi

# Directory environment
if [ -x "$(command -v direnv)" ]; then
    eval "$(direnv hook zsh)"
fi

# Ruby version management
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"
fi
```

**GNU Coreutils Integration**:
```zsh
prefix=${HOMEBREW_PREFIX:-/usr/local}
if [ -d "$prefix/opt/coreutils/libexec/gnubin" ]; then
    PATH="$prefix/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="$prefix/opt/coreutils/libexec/gnuman:$MANPATH"
fi
```

### Internationalization (`~/.zsh/locale.zsh`)

**Hybrid Locale Configuration**:
- `LANG="en_US.UTF-8"`: Base language (English)
- `LC_COLLATE=C`: ASCII collation order for consistent sorting
- German locales for regional formats:
  - `LC_MONETARY`, `LC_NUMERIC`: German number/currency formats
  - `LC_TIME`, `LC_DATE`: German date/time formats
  - `LC_MEASUREMENT`, `LC_PAPER`: Metric system, A4 paper

### Terminal Integration (`~/.zsh/x.zsh`)

**Dynamic Terminal Titles**:
```zsh
case $TERM in
    *xterm*|rxvt|(dt|k|E)term)
        function set_terminal_title() {
            print -Pn "\e]0;%n@%m: %~\a"
        }
        precmd_functions+=(set_terminal_title)
    ;;
esac
```

## Design Philosophy

### Performance Optimizations
- **Lazy Loading**: Modules only loaded when needed
- **Caching**: Completion results cached for speed
- **Efficient Globbing**: Optimized file matching patterns
- **Minimal Startup**: Essential features loaded first

### Cross-Platform Compatibility
- **Architecture Detection**: ARM64 vs x86_64 handling
- **OS-Specific Paths**: Adaptive PATH management
- **Tool Detection**: `qwhich` function for conditional aliasing
- **Terminal Adaptation**: Context-aware prompt behavior

### User Experience
- **Visual Feedback**: Color-coded loading and status indicators
- **Progressive Enhancement**: Graceful degradation when tools unavailable
- **Contextual Information**: Rich prompt with VCS and environment info
- **Comprehensive Help**: Built-in documentation system

### Maintainability
- **Modular Structure**: Each feature in separate file
- **Clear Naming**: Descriptive file and function names
- **Error Handling**: Graceful handling of missing dependencies
- **Documentation**: Extensive inline comments and help functions

## File Structure Summary

```
~/.zsh/
├── func/
│   └── load_zshd           # Modular loading system
├── plugins/
│   ├── autosuggestions.zsh # Fish-like suggestions
│   └── zsh-syntax-highlighting.zsh
├── aliases.zsh             # Global aliases and shortcuts
├── asdf.zsh               # ASDF version manager
├── completion.zsh         # Advanced completion system
├── ext.zsh                # Development environment setup
├── help.zsh               # Built-in documentation
├── history.zsh            # History configuration
├── keys.zsh               # Key bindings and terminal detection
├── locale.zsh             # Internationalization settings
├── m1brew.zsh             # Homebrew platform handling
├── options.zsh            # Core Zsh options
├── prompt.zsh             # Prompt and VCS integration
└── x.zsh                  # Terminal integration

~/.zshrc                   # Platform-conditional entry point
~/.alias                   # Command aliases and functions
```

This configuration represents a sophisticated, production-ready Zsh setup optimized for cross-platform development workflows with extensive customization and performance optimizations.