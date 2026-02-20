# Default branch resolution: per-repo git config > "main"
# Override per-repo: git config default-branch.name stable
_git_default_branch() {
  git config --get default-branch.name 2>/dev/null || echo "main"
}

# git fresh [branch] — update local branch from remote, check it out
_git_fresh() {
  local branch="${1:-$(_git_default_branch)}"
  git fetch origin "$branch" || return 1
  git checkout "$branch" || return 1
  git rebase "origin/$branch"
}

# git sync [flags] [branch] — fetch branch from remote, rebase current branch on it
# Flags (e.g. -i) are passed through to the rebase
_git_sync() {
  local branch="$(_git_default_branch)"
  local -a rebase_args=()

  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      rebase_args+=("$arg")
    else
      branch="$arg"
    fi
  done

  git fetch origin "$branch" || return 1
  # Update local branch ref if we're not currently on it
  local current
  current=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$current" != "$branch" ]]; then
    git branch -f "$branch" "origin/$branch" 2>/dev/null
  fi
  git rebase "${rebase_args[@]}" "$branch"
}

# Wrapper so "git fresh" and "git sync" invoke the functions above
git() {
  case "$1" in
    fresh) shift; _git_fresh "$@" ;;
    sync)  shift; _git_sync "$@"  ;;
    *)     command git "$@" ;;
  esac
}
