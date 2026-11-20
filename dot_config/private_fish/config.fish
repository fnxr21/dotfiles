#if status is-interactive
# Commands to run in interactive sessions can go here
#end
set fish_greeting ""
set -gx TERM xterm-256color
set -gx LANG en_US.UTF-8
# Make macOS tools (lazygit, ...) read ~/.config instead of ~/Library/Application Support
set -gx XDG_CONFIG_HOME $HOME/.config

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases (ls is set per OS in config-osx.fish / config-linux.fish)
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias c claude
alias python=python3
alias claude-yolo "claude --dangerously-skip-permissions"
alias pn pnpm
alias cz chezmoi

# browser: Helium if installed, else Chrome
function b
    if test -d /Applications/Helium.app
        open -a Helium $argv
    else
        open -a "Google Chrome" $argv
    end
end
#nvim
command -qv nvim && alias vim nvim
set -gx EDITOR nvim

# Go versions: writes mise.toml in the current folder (like "asdf set" did)
function go_19
    mise use go@1.19.1
end

function go_21
    mise use go@1.21.13
end

function go_24
    mise use go@1.24.0
end

function go_26
    mise use go@1.26.1
end

# PATH: my scripts (~/bin: ide, herdr-move-workspace), pip/uv tools, Go and Rust binaries.
# fish_add_path skips folders that do not exist.
set -gx GOPATH $HOME/go
fish_add_path -g ~/bin ~/.local/bin $GOPATH/bin ~/.cargo/bin

switch (uname)
    case Darwin
        source (dirname (status --current-filename))/config-osx.fish
    case Linux
        source (dirname (status --current-filename))/config-linux.fish
end

# eza overrides the per-OS ls aliases when installed
if type -q eza
    alias ls "eza --group-directories-first --icons"
    alias la "eza -a --group-directories-first --icons"
    alias ll "eza -l -g --icons --group-directories-first"
    alias lla "eza -la -g --icons --group-directories-first"
end

# mise: puts go/node/... from mise.toml and .tool-versions on PATH.
# Homebrew's mise turns itself on (vendor_conf.d); this covers other installs (Linux).
if type -q mise; and not set -q MISE_SHELL
    mise activate fish | source
end

# Machine-only settings (not in git): ~/.config/fish/config-local.fish
set -l local_config (dirname (status --current-filename))/config-local.fish
test -f $local_config; and source $local_config
