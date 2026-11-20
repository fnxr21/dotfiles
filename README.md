# Dotfiles

My core setup: **fish** shell, **nvim** editor, **tmux**, **ghostty** terminal, git, htop, VS Code Insiders settings.
Works on **macOS (Apple Silicon)** and **Linux (Ubuntu)**.

Managed with [chezmoi](https://www.chezmoi.io/): one command clones, links, installs tools and plugins.

---

## Contents

1. [New laptop: quick start](#1-new-laptop-quick-start)
2. [What is inside](#2-what-is-inside)
3. [How chezmoi works here](#3-how-chezmoi-works-here)
4. [How to use: shell, aliases, functions](#4-how-to-use-shell-aliases-functions)
5. [Settings: tmux, nvim, ghostty, git](#5-settings-tmux-nvim-ghostty-git)
6. [Daily work: add, update, remove](#6-daily-work-add-update-remove)
7. [Security rules](#7-security-rules)
8. [Test the install safely](#8-test-the-install-safely)
9. [Troubleshooting](#9-troubleshooting)

Git branches and commit messages: see [GIT-FLOW.md](GIT-FLOW.md).

---

## 1. New laptop: quick start

### macOS (M1 / M2 / M3)

```bash
# 1. Homebrew (installs to /opt/homebrew)
#    Get the command from https://brew.sh and run it.
# 2. chezmoi + clone
brew install chezmoi
git clone git@github.com:fnxr21/.dotfiles.git ~/.dotfiles
# 3. Make the config (asks your git name + email once), then look first (changes nothing)
chezmoi init --source ~/.dotfiles
chezmoi diff
# 4. Apply: brew bundle, links, git hooks, fish plugins
chezmoi apply -v
# 5. Make fish the default shell
echo "$(command -v fish)" | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"
# 6. Open a new terminal (Ghostty), then set the prompt look once:
tide configure
```

### Linux (Ubuntu / Debian)

```bash
sudo apt install -y git curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
git clone git@github.com:fnxr21/.dotfiles.git ~/.dotfiles
~/.local/bin/chezmoi init --source ~/.dotfiles
~/.local/bin/chezmoi diff
~/.local/bin/chezmoi apply -v     # apt install asks for sudo
chsh -s "$(command -v fish)"
tide configure
```

Some tools are **not in apt**. Install them by hand on Linux:

| tool | why | how |
|---|---|---|
| neovim ≥ 0.10 | LazyVim needs a new version | download from github.com/neovim/neovim/releases, unpack to `/opt/nvim` (fish adds `/opt/nvim/bin` to PATH) |
| ghostty | terminal | see ghostty.org/docs/install |
| mise | Go / Node versions (`go_19`, `go_24` …) | `curl https://mise.run \| sh` (see mise.jdx.dev) |
| git-delta | git pager | github.com/dandavison/delta releases |
| lazygit | tmux `prefix + g` | github.com/jesseduffield/lazygit releases |
| gitleaks | secret scan | github.com/gitleaks/gitleaks releases |
| PlemolJP Console NF | ghostty font | github.com/yuru7/PlemolJP releases → `~/.local/share/fonts` |
| VS Code Insiders | editor | code.visualstudio.com/insiders |

> On Ubuntu, `fd` is called `fdfind`. Fix: `ln -s (command -v fdfind) ~/.local/bin/fd`

---

## 2. What is inside

The repo root is the chezmoi **source**. A name tells chezmoi where the file goes:
`dot_config/private_fish/config.fish` → `~/.config/fish/config.fish`.

```
~/.dotfiles/
├── .chezmoi.toml.tmpl      chezmoi config: asks name/email, symlink mode, sourceDir
├── .chezmoiignore          repo files that are not dotfiles (README, Brewfile …)
├── .chezmoitemplates/      shared file bodies (VS Code settings)
├── run_onchange_*.sh.tmpl  scripts chezmoi runs on apply (packages, git hooks, fish plugins)
├── create_dot_gitconfig.local.tmpl   makes ~/.gitconfig.local once
├── Brewfile                macOS packages  (brew bundle)
├── packages-linux.txt      Linux packages  (apt)
├── .gitignore              blocks secrets and machine state
├── .gitleaks.toml          secret scanner config
├── vendor/fisher.fish      pinned fisher (plugin manager)
├── dot_config/  ──▶ ~/.config/
│   ├── _doc/               my notes (tmux, AI tools)
│   ├── fish/               shell
│   ├── nvim/               editor (LazyVim)
│   ├── tmux/               terminal multiplexer
│   ├── herdr/              workspace manager for AI agents
│   ├── ghostty/            terminal
│   ├── git/                git aliases + delta pager
│   ├── gwq/                git worktrees
│   ├── mise/               Go / Node versions
│   ├── htop/               process viewer
│   ├── enchant/            my spell-check word list
│   ├── git-secrets/        global.gitignore + secret patterns
│   └── claude-secure/      Claude Code secret protection kit
├── dot_gitconfig ──▶ ~/.gitconfig
├── dot_gitmessage ──▶ ~/.gitmessage
├── dot_claude/   ──▶ ~/.claude/ (settings.json, CLAUDE.md)
└── private_Library/private_Application Support/private_Code - Insiders/User/settings.json.tmpl ──▶ VS Code Insiders (macOS)
    dot_config/Code - Insiders/User/settings.json.tmpl        ──▶ VS Code Insiders (Linux)
```

| source | target | what it is |
|---|---|---|
| `dot_config/private_fish` | `~/.config/fish` | `config.fish` (all OS), `config-osx.fish`, `config-linux.fish`, `fish_plugins`, my functions. Plugin files are **not** in git: fisher installs them from `fish_plugins` |
| `dot_config/nvim` | `~/.config/nvim` | LazyVim. `lazy-lock.json` pins plugin versions |
| `dot_config/tmux` | `~/.config/tmux` | `tmux.conf` + `macos.conf` / `linux.conf` + statusline + utility |
| `dot_config/ghostty` | `~/.config/ghostty` | theme, font, opacity |
| `dot_config/htop` | `~/.config/htop` | htop layout |
| `dot_config/enchant` | `~/.config/enchant` | personal dictionary (Linux apps) |
| `dot_config/git-secrets` | `~/.config/git-secrets` | `global.gitignore` (used by git `core.excludesFile`) and `patterns` |
| `dot_config/claude-secure` | `~/.config/claude-secure` | `apply.sh` + templates (see §4) |
| `dot_gitconfig` | `~/.gitconfig` | shared git settings. Includes `~/.gitconfig.local` |
| `dot_claude/settings.json` | `~/.claude/settings.json` | Claude Code user settings |
| `.chezmoitemplates/vscode-settings.json` | macOS: `~/Library/Application Support/Code - Insiders/User/` · Linux: `~/.config/Code - Insiders/User/` | VS Code settings |

**chezmoi name prefixes used here:** `dot_` → leading `.` · `executable_` → chmod +x ·
`empty_` → keep an empty file · `private_` → chmod 700 · `create_` → only make it if missing · `.tmpl` → template.

**Not in this repo (on purpose):** logins, sessions, caches, `fish_variables`, `~/.ssh`, cloud configs (gcloud …),
Linux desktop state (dconf, gnome, monitors …), `go/env`, API keys.

---

## 3. How chezmoi works here

```bash
chezmoi diff                 # what apply would change (changes nothing)
chezmoi apply -v             # links + scripts
chezmoi apply -v --exclude=scripts   # only links, no installs / downloads
chezmoi managed              # list every file chezmoi owns
chezmoi doctor               # check the setup
```

**Symlink mode** (`mode = "symlink"` in `.chezmoi.toml.tmpl`): most targets are **links** into this repo,
like stow made before. Edit `~/.config/fish/config.fish` normally; the change is already in the repo.
Templates (`.tmpl`), executables and `create_` files are **copies** instead: edit those in the repo
(`chezmoi edit <target>`), then `chezmoi apply`.

Scripts (run by `chezmoi apply`, in this order):

1. `run_onchange_before_10-install-packages-*`: `brew bundle` on macOS, `apt-get install` (+ gitleaks download) on Linux.
   Runs again **only when `Brewfile` / `packages-linux.txt` changes** (the file hash is inside the script).
2. *(files are linked)*
3. `run_onchange_after_20-install-git-hooks`: installs git-secrets hooks into `~/.git-templates/git-secrets`,
   plus the claude-secure `pre-commit`, `commit-msg`, `pre-push` and `post-checkout` hooks
   (new repos get them on `git init` **and** `git clone`, from any terminal). Runs again when a hook changes.
4. `run_onchange_after_30-install-fish-plugins`: loads `vendor/fisher.fish` and runs `fisher update`.
   Runs again when `fish_plugins` changes. This step downloads code (from GitHub).

`~/.gitconfig.local` is made **once** from the name/email you typed on `chezmoi init`. Later edits are yours;
chezmoi never overwrites it. Change the saved answers: `chezmoi init --source ~/.dotfiles --prompt`.

**Run a script again by hand:** `chezmoi state delete-bucket --bucket=entryState` re-runs all `run_onchange_` scripts on the next apply.

**Undo:** `chezmoi purge` removes chezmoi's config and state (your links stay). Remove a link: `rm ~/.config/x/file`.

---

## 4. How to use: shell, aliases, functions

### Fish plugins (`dot_config/private_fish/fish_plugins`)

| plugin | what it gives you |
|---|---|
| `jorgebucaran/fisher` | plugin manager: `fisher list`, `fisher update`, `fisher install <user/repo>` |
| `ilancosman/tide@v6` | the prompt. Change the look: `tide configure` |
| `patrickf1/fzf.fish` | fuzzy search keys (below) |
| `jethrokuan/z` | jump to folders: `z proj` goes to your most used folder matching "proj" |
| `danhper/fish-ssh-agent` | starts `ssh-agent` once and shares it between shells |

**fzf.fish keys:**

| key | search |
|---|---|
| `Ctrl+R` | command history |
| `Ctrl+Alt+F` | files in this folder |
| `Ctrl+Alt+L` | git log |
| `Ctrl+Alt+S` | git status |
| `Ctrl+Alt+P` | processes |
| `Ctrl+V` | shell variables |

### Aliases (`config.fish`)

| alias | runs |
|---|---|
| `g` | `git` |
| `c` | `claude` |
| `vim` | `nvim` (if installed) |
| `python` | `python3` |
| `claude-yolo` | `claude --dangerously-skip-permissions` |
| `pn` | `pnpm` |
| `cz` | `chezmoi` |
| `ls` | `ls -p` with colors (macOS `-G`, Linux `--color=auto`) |
| `la` / `ll` / `lla` | all / long / long + all |

`EDITOR` is `nvim`. `LANG` is `en_US.UTF-8`. `XDG_CONFIG_HOME` is `~/.config` (so lazygit reads `~/.config/lazygit` on macOS).

PATH adds `~/bin` (my scripts), `~/.local/bin`, `~/go/bin`, `~/.cargo/bin` (only the ones that exist).
Machine-only settings: put them in `~/.config/fish/config-local.fish` (not in git); it is loaded last.

### Go / Node versions (mise)

`go_19`, `go_21`, `go_24`, `go_26` → `mise use go@<version>` in the current folder (writes `mise.toml`).
Global defaults are in `dot_config/mise/config.toml`. mise also reads old `.tool-versions` and `.nvmrc` files.

### My functions (`dot_config/private_fish/functions/`)

| function | what it does |
|---|---|
| `make` | runs `make`; if a line has JSON, it prints it pretty with `jq`. Note: it hides make's exit code |
| `git` | normal `git`, but after `git init` it also runs `claude-secure` on the new repo. Skip once: `CLAUDE_SECURE_SKIP=1 git init` |
| `claude-secure [dir]` | adds Claude Code secret protection to a project: `.claude/hooks/protect_secrets.py`, `.claude/settings.json` (merged), `CLAUDE.md` (appended), `.gitignore` lines, git hooks (pre-commit + git-secrets). `.claude/` and `CLAUDE.md` go in `.gitignore`, so they stay on your machine. Safe to run again |
| `claude-secure --local [dir]` | same, for **someone else's** project: writes `.claude/settings.local.json`, `.claude/CLAUDE.md` and `.git/info/exclude` instead, so `git status` stays clean. Runs by itself after `git clone` |
| `fish_mode_prompt` | empty: hides the vi-mode label |
| `fzf_change_directory` (**Ctrl+F**) | fuzzy-pick a repo under `~/fn` (worktrees too), `~/.dotfiles`, `~/.config` or a sub folder, and `cd` there |
| `claude_commit` | Claude Code stages (if nothing is staged), writes a Conventional Commit message and commits. Never pushes. Also `C` in lazygit |
| `cpwd` | copy the current folder (with `~`) to the clipboard |
| `envsource .env` | export every `KEY=value` line of a file into the shell |

**My scripts (`bin/` → `~/bin`):** `ide` splits the window into editor + 3 panes (herdr, Rex or tmux) ·
`herdr-move-workspace up|down` (herdr `Ctrl+Shift+↑/↓`).

### OS-specific fish settings

`config.fish` ends with:

```fish
switch (uname)
    case Darwin
        source .../config-osx.fish     # Homebrew shellenv (/opt/homebrew), ls -G
    case Linux
        source .../config-linux.fish   # greeting, ls --color, /opt/nvim/bin in PATH
end
```

Put Mac-only things in `config-osx.fish`, Linux-only things in `config-linux.fish`.

---

## 5. Settings: tmux, nvim, ghostty, git

### tmux

Prefix is **`Ctrl+t`** (not `Ctrl+b`).

| keys | action |
|---|---|
| `prefix` `\|` | split left / right |
| `prefix` `-` | split top / bottom |
| `prefix` `h` `j` `k` `l` | move between panes |
| `prefix` `Ctrl+h/j/k/l` | resize pane (5 cells) |
| `prefix` `e` | close all other panes |
| `prefix` `r` | reload config |
| `prefix` `o` | open current folder (Finder / file manager) |
| `prefix` `g` | lazygit popup |
| `Ctrl+Shift+←/→` | move window left / right |

Copy mode uses vi keys. Files: `tmux.conf` (main), `statusline.conf` (colors/status bar),
`utility.conf` (lazygit), `macos.conf` / `linux.conf` (per OS). More notes: `dot_config/_doc/tmux/tmux.md`.

### herdr

`dot_config/herdr/config.toml`: workspace manager for running several Claude sessions side by side.
Same prefix (`Ctrl+t`) and keys as tmux, so use it **instead of** tmux, not inside it.
Extra: `prefix` `b` toggles the agent sidebar, `prefix` `u` jumps to a workspace,
`Ctrl+Shift+[` / `]` switches workspaces.

### gwq

`dot_config/gwq/config.toml`: one git worktree per branch, in `~/fn/worktrees/<host>/<owner>/<repo>@<branch>`.
Run a separate Claude session on each branch without stashing.

```bash
gwq add -b feature/x    # new branch + worktree
gwq list                # list worktrees
cd $(gwq get feature/x) # jump in
gwq remove feature/x    # delete the worktree when merged
```

### lazygit

`dot_config/lazygit/config.yml`: diffs in delta, no auto fetch, no mouse. In the files panel, `C` runs `claude_commit`.

### nvim

LazyVim starter. First start installs plugins (needs internet).
- Your options: `lua/config/options.lua` · keymaps: `lua/config/keymaps.lua` · plugins: `lua/plugins/*.lua`
- `lazy-lock.json` pins plugin versions. Update: `:Lazy update`, then commit the new lock file.
- Health check: `:checkhealth`
- Needs: `git`, `ripgrep`, `fd`, a C compiler, `lazygit` (optional).

### ghostty

`dot_config/ghostty/config.ghostty`: theme "Solarized Dark - Patched" (in `themes/`), font
**PlemolJP Console NF**, opacity 0.9, blur. `macos-option-as-alt = left` (macOS only, ignored on Linux).
Reload: `Cmd+Shift+,` (macOS) / `Ctrl+Shift+,` (Linux).

### git

- `dot_gitconfig`: shared settings (pull, bitbucket SSH url, git-secrets rules, hooks template, global ignore).
  At the end: includes `~/.config/git/aliases.gitconfig`, `~/.config/git/delta.gitconfig`, then `~/.gitconfig.local`.
- `nvim` is the commit editor, `git difftool` / `git mergetool` open `nvim -d`. New repos start on `main`. Git LFS filter is on (brew `git-lfs`).
- `dot_config/git/delta.gitconfig`: diffs go through **delta** (line numbers, syntax colors). `n` / `N` jump between files.
- `dot_config/git/aliases.gitconfig`: `st`, `co`, `br`, `d`, `hist` (graph of all branches), `llog`, `ps` / `pl` (push / pull the current branch), `open` (repo in browser via `gh`), `edit-unmerged` / `add-unmerged`.
- `~/.gitconfig.local`: **your name and email**. Not in git. Template: `gitconfig.local.example`.
- `core.excludesFile` = `~/.config/git-secrets/global.gitignore` → ignored in **every** repo.
- `init.templateDir` = `~/.git-templates/git-secrets` → every new repo gets these hooks (any terminal, VS Code, scripts):

  | hook | when | does |
  |---|---|---|
  | `pre-commit` | every commit | blocks secret file names, runs git-secrets, runs gitleaks (if installed). If the repo has no `.claude/` protection yet, adds it |
  | `commit-msg` | every commit | Conventional Commits format, subject <= 72 chars, no emoji; then git-secrets on the message |
  | `prepare-commit-msg` | every commit | git-secrets on the message |
  | `pre-push` | every push | blocks pushes to `main`/`master` (use a PR). See [GIT-FLOW.md](GIT-FLOW.md) |
  | `post-checkout` | right after `git clone` | runs `claude-secure --local` (skips tool folders like `~/.local`, `~/.cache`, Homebrew). Skip once: `CLAUDE_SECURE_SKIP=1 git clone ...` |

  Old repos (made before this): run `claude-secure` (own repo) or `claude-secure --local` (someone else's) inside them.
- Guide: `dot_config/git-secrets/readme_first_step.md`

### VS Code Insiders

Only `settings.json` is shared. Extensions are not.
**WakaTime API key is NOT in this file.** Put it in `~/.wakatime.cfg`:

```ini
[settings]
api_key = YOUR_WAKATIME_API_KEY
```

### Claude Code

`dot_claude/settings.json` = user settings. Install Claude Code: see `dot_config/_doc/ai/claude-code.md`.
9router (optional): `dot_config/_doc/ai/9router.md`.

---

## 6. Daily work: add, update, remove

Most files in `~/.config` are **links** to this repo. Edit them normally; the change is already in the repo.

```bash
chezmoi cd                  # opens a shell in ~/.dotfiles
git status
git diff
gitleaks git . --redact -v && gitleaks dir . --redact -v   # secret scan
git add -A && git commit -m "feat(fish): add alias"
git push
```

**Add a new config** (example: `~/.config/lazygit/config.yml`):

```bash
chezmoi add ~/.config/lazygit/config.yml    # copies it to dot_config/lazygit/config.yml
chezmoi apply -v                            # replaces the file with a link to the repo
```

**Update on another machine:**

```bash
chezmoi update -v       # git pull + apply (runs package scripts if the lists changed)
```

**Add a fish plugin:** `fisher install user/repo` (it also updates `fish_plugins`), then commit.

**Add a package:** add a line to `Brewfile` / `packages-linux.txt`, then `chezmoi apply` installs it.

**Stop managing one file:** `chezmoi forget ~/.config/x/file`, then `rm` the link and copy the file back from the repo.

---

## 7. Security rules

- **Never commit** `.env`, keys (`*.pem`, `*.key`, `id_*`), `*credential*.json`, tokens, `auth.json`, `hosts.yml`.
  `.gitignore` blocks most of them, but **always check `git status` before commit**.
- Secrets go into env vars, `~/.gitconfig.local`, `~/.wakatime.cfg`, or a secret manager. Not into this repo.
- **Scan before push:**
  ```bash
  gitleaks git . --redact -v      # all git history
  gitleaks dir . --redact -v      # current files
  git secrets --scan
  ```
  `.gitleaks.toml` only allows the **fake** example keys in `dot_config/git-secrets/readme_first_step.md`.
- **If a secret was committed:** deleting it is **not enough** (it stays in git history).
  1. **Rotate** the key at the provider (make a new one, turn off the old one).
  2. Then clean history (e.g. `git filter-repo`) and force-push. Only after step 1.
- Check if the GitHub repo is public or private: GitHub → repo → Settings → "Danger Zone" / visibility.

---

## 8. Test the install safely

Use a **fake HOME**, so your real files are not touched:

```bash
T=$(mktemp -d)
chezmoi execute-template --init --source ~/.dotfiles \
  --promptString "Git user name=test" --promptString "Git email=test@example.com" \
  < ~/.dotfiles/.chezmoi.toml.tmpl > $T/chezmoi.toml            # 1. config, no questions
C="chezmoi --config $T/chezmoi.toml --source ~/.dotfiles --destination $T/home"
mkdir $T/home
$C diff --exclude=scripts | head -40                            # 2. only print
$C apply -v --exclude=scripts                                   # 3. real run, in the fake home
find $T/home -type l ! -exec test -e {} \; -print               # 4. broken links? (should print nothing)
$C apply -v --exclude=scripts                                   # 5. run again: nothing new should happen
rm -rf "$T"                                                     # 6. clean up
```

---

## 9. Troubleshooting

| problem | fix |
|---|---|
| `chezmoi: ... has changed since chezmoi last wrote it` | the target was edited outside chezmoi (e.g. a copied template). Keep yours: `chezmoi merge <file>` or `chezmoi re-add`; take the repo's: `chezmoi apply --force <file>` |
| `config file template has changed` | `.chezmoi.toml.tmpl` changed: run `chezmoi init --source ~/.dotfiles` |
| prompt looks plain | `fisher update`, then `tide configure` |
| `fd` not found on Ubuntu | `ln -s (command -v fdfind) ~/.local/bin/fd` |
| nvim errors on start | neovim too old (need ≥ 0.10): `nvim --version` |
| tmux clipboard on macOS | `brew install reattach-to-user-namespace` |
| git says "please tell me who you are" | fill in `~/.gitconfig.local` |
| htop changed the link into a normal file | htop rewrites its file on exit. `chezmoi re-add ~/.config/htop/htoprc`, then `chezmoi apply` |
