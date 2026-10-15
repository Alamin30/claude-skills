#!/usr/bin/env bash
# Print one day's commits by the current git user across local repos.
#
# Usage: collect.sh [YYYY-MM-DD]          (default: today)
#
# Env:
#   STANDUP_DIRS     colon-separated parent folders to scan for repos
#                    (default: whichever of ~/Sites ~/Projects ~/projects ~/code ~/dev ~/src ~/work exist)
#   STANDUP_AUTHORS  colon-separated extra author names/emails to match
#                    (git config user.name and user.email are always included)

set -u

day="${1:-$(date +%Y-%m-%d)}"

if ! [[ "$day" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "error: date must be YYYY-MM-DD, got '$day'" >&2
  exit 2
fi

# Next day: GNU date first, then BSD/macOS date.
next=$(date -d "$day +1 day" +%Y-%m-%d 2>/dev/null) ||
  next=$(date -j -v+1d -f %Y-%m-%d "$day" +%Y-%m-%d 2>/dev/null) || {
    echo "error: could not compute the day after $day" >&2
    exit 2
  }

authors=()
name=$(git config --global user.name 2>/dev/null) && [ -n "$name" ] && authors+=("--author=$name")
email=$(git config --global user.email 2>/dev/null) && [ -n "$email" ] && authors+=("--author=$email")
if [ -n "${STANDUP_AUTHORS:-}" ]; then
  IFS=':' read -r -a extra <<< "$STANDUP_AUTHORS"
  for a in "${extra[@]}"; do [ -n "$a" ] && authors+=("--author=$a"); done
fi
if [ ${#authors[@]} -eq 0 ]; then
  echo "error: no git user.name/user.email configured and STANDUP_AUTHORS is empty" >&2
  exit 2
fi

dirs=()
if [ -n "${STANDUP_DIRS:-}" ]; then
  IFS=':' read -r -a dirs <<< "$STANDUP_DIRS"
else
  for d in "$HOME/Sites" "$HOME/Projects" "$HOME/projects" "$HOME/code" "$HOME/dev" "$HOME/src" "$HOME/work"; do
    [ -d "$d" ] && dirs+=("$d")
  done
fi
if [ ${#dirs[@]} -eq 0 ]; then
  echo "error: no repo folders found; set STANDUP_DIRS" >&2
  exit 2
fi

echo "# day: $day (until $next)"
echo "# dirs: ${dirs[*]}"

found=0
for parent in "${dirs[@]}"; do
  parent="${parent/#\~/$HOME}"
  for repo in "$parent"/*/; do
    [ -d "$repo/.git" ] || [ -f "$repo/.git" ] || continue
    commits=$(git -C "$repo" log --all --no-merges --since="$day 00:00" --until="$next 00:00" \
      "${authors[@]}" --pretty='%h %ad %s' --date=format:%H:%M 2>/dev/null)
    [ -n "$commits" ] || continue
    found=1
    printf '== %s\n%s\n' "$(basename "$repo")" "$commits"
    prs=$(git -C "$repo" log --all --merges --since="$day 00:00" --until="$next 00:00" \
      --pretty='%h %s' 2>/dev/null | grep 'Merge pull request')
    [ -n "$prs" ] && printf -- '-- merged PRs\n%s\n' "$prs"
    branch=$(git -C "$repo" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && printf -- '-- current branch: %s\n' "$branch"
  done
done

[ "$found" -eq 1 ] || echo "# no commits found"
