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

# git tidy — delete local branches fully merged into the default branch
_git_tidy() {
  local default_branch="$(_git_default_branch)"
  local current
  current=$(git symbolic-ref --short HEAD 2>/dev/null)

  local -a to_delete=()
  local branch
  for branch in $(git branch --merged "$default_branch" --format='%(refname:short)'); do
    # Never delete the default branch or the current branch
    [[ "$branch" == "$default_branch" || "$branch" == "$current" ]] && continue
    to_delete+=("$branch")
  done

  if (( ${#to_delete} == 0 )); then
    echo "No merged branches to clean up."
    return 0
  fi

  echo "Branches merged into $default_branch:"
  printf '  %s\n' "${to_delete[@]}"
  echo ""
  read -q "?Delete these branches? [y/N] " || { echo; return 0; }
  echo

  for branch in "${to_delete[@]}"; do
    git branch -d "$branch"
  done
}

# Wrapper so "git fresh", "git sync", and "git tidy" invoke the functions above
git() {
  case "$1" in
    fresh) shift; _git_fresh "$@" ;;
    sync)  shift; _git_sync "$@"  ;;
    tidy)  shift; _git_tidy "$@"  ;;
    *)     command git "$@" ;;
  esac
}
