# Ctrl+F: fuzzy-pick a git repo (or a sub folder of this one) and cd into it.
# Repos are found under ~/fn (work, freelance, lab, ...; gwq worktrees too).
function _list_repo_directories
    # .git is a folder in a clone and a file in a worktree
    fd -HI -t d -t f --max-depth 5 '^\.git$' ~/fn \
        | string replace -r '/\.git/?$' ''
    printf '%s\n' ~/.dotfiles ~/.config
    ls -ad */ 2>/dev/null | string replace -r '^' "$PWD/"
end

function fzf_change_directory --description 'Fuzzy cd into a repo'
    _list_repo_directories | string replace -r '/$' '' | string replace -r "^$HOME" '~' | awk '!a[$0]++' \
        | fzf --layout reverse | read -l selection
    if test -n "$selection"
        builtin cd (string replace -r '^~' $HOME -- $selection)
    end
    commandline -r ''
    commandline -f repaint
end
