function claude_commit --description 'Commit with Claude Code, printing progress as it runs'
    set -l progress_filter '
        if .type == "system" and .subtype == "init" then "● Claude Code started"
        elif .type == "assistant" then
            .message.content[]
            | if .type == "thinking" then "● Thinking…"
              elif .type == "tool_use" then "$ " + (.input.command // .name)
              elif .type == "text" then "\n" + .text
              else empty end
        elif .type == "user" then
            .message.content[]?
            | select(.type == "tool_result")
            | .content
            | if type == "array" then map(.text // "") | join("\n") else tostring end
        else empty end'

    set -l prompt 'Commit the changes in this git repo.
If nothing is staged, stage all changes first with git add -A.
Read git status, git diff --cached and git log -5 --oneline.
Message: Conventional Commits "<type>(<scope>): <summary>", lowercase, imperative, no period, max 72 chars,
no emoji, no Co-Authored-By or "Generated with" lines. Small change: subject only.
Many changes: blank line, then one "- " bullet per change. Then run git commit. Do not push.'

    claude -p $prompt \
        --allowedTools "Bash(git add:*)" "Bash(git commit:*)" "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" \
        --output-format stream-json --verbose </dev/null \
        | jq --unbuffered -r $progress_filter
end
