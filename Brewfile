# macOS packages. chezmoi installs them on "chezmoi apply" whenever this file changes.
# By hand:  brew bundle --file ~/.dotfiles/Brewfile

tap "d-kuro/tap"                    # gwq

# core
brew "git"
brew "chezmoi"
brew "fish"
brew "tmux"
brew "neovim"
brew "reattach-to-user-namespace"   # tmux clipboard (macos.conf)

# tools used by the configs
brew "fzf"          # fzf.fish plugin
brew "fd"           # fzf.fish file search
brew "bat"          # fzf.fish file preview
brew "ripgrep"      # nvim / LazyVim search
brew "lazygit"      # tmux prefix+g, nvim
brew "jq"           # fish "make" function
brew "htop"
brew "mise"         # go/node versions (go_19 / go_21 / ... functions), reads .tool-versions
brew "git-delta"    # git pager (config/git/delta.gitconfig)
brew "gh"           # GitHub CLI, "git open" alias
brew "d-kuro/tap/gwq"  # git worktrees for parallel Claude sessions
brew "herdr"        # workspace manager for AI agents (config/herdr)
brew "git-lfs"      # large files (filter "lfs" in .gitconfig)
brew "tig"          # git log browser
brew "btop"         # process monitor
brew "tree"
brew "wget"
brew "ffmpeg"
brew "apm"          # dependency manager for AI agent configuration

# security
brew "git-secrets"
brew "gitleaks"

# apps + font
cask "ghostty"
cask "visual-studio-code@insiders"
cask "raycast"
cask "cleanshot"
cask "transmit"
cask "chatgpt"
cask "imageoptim"
cask "numi"
cask "font-plemol-jp-nf"            # ghostty font "PlemolJP Console NF"
