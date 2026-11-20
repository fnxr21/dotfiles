function fish_user_key_bindings
    # Ctrl+F: fuzzy cd into a repo (replaces "accept autosuggestion"; use the right arrow for that)
    bind \cf fzf_change_directory
end
