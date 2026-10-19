#!/usr/bin/env bash
# Replays the ws397 patch stack (<old-tag>..ws397) onto a new upstream release tag.
#
#   scripts/port-to-tag.sh <new-tag> [<old-tag>]
#
# Creates release/<new-tag>-ws397 from <new-tag>, cherry-picks the stack onto it and builds
# ws397-gh_release. <old-tag> defaults to the upstream tag ws397 is currently based on.
# Never moves ws397, creates tags or pushes; it prints those steps instead.
#
# Environment: PORT_BRANCH (default ws397), UPSTREAM_REMOTE (default upstream), SKIP_BUILD=1.

set -euo pipefail

main() {
  local port_branch="${PORT_BRANCH:-ws397}"
  local upstream="${UPSTREAM_REMOTE:-upstream}"
  local new_tag="${1:-}"
  local old_tag="${2:-}"

  if [[ -z "$new_tag" ]]; then
    echo "usage: $0 <new-tag> [<old-tag>]" >&2
    exit 2
  fi

  cd "$(git rev-parse --show-toplevel)"

  if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "error: working tree has uncommitted changes" >&2
    exit 1
  fi

  if git remote get-url "$upstream" >/dev/null 2>&1; then
    git fetch "$upstream" --tags
  else
    echo "warning: remote '$upstream' not found, using local tags only" >&2
  fi

  if ! git rev-parse -q --verify "refs/tags/$new_tag" >/dev/null; then
    echo "error: tag '$new_tag' not found" >&2
    exit 1
  fi

  if [[ -z "$old_tag" ]]; then
    old_tag="$(git describe --tags --abbrev=0 --exclude '*-ws397*' "$port_branch")"
  fi

  if [[ "$(git rev-parse "$old_tag^{commit}")" == "$(git rev-parse "$new_tag^{commit}")" ]]; then
    echo "error: $port_branch is already based on $new_tag" >&2
    exit 1
  fi

  local release_branch="release/$new_tag-ws397"
  if git rev-parse -q --verify "refs/heads/$release_branch" >/dev/null; then
    echo "error: branch '$release_branch' already exists" >&2
    exit 1
  fi

  echo "Patch stack $old_tag..$port_branch:"
  git log --oneline --reverse "$old_tag..$port_branch"
  echo

  git switch -c "$release_branch" "$new_tag"

  if ! git cherry-pick --empty=drop "$old_tag..$port_branch"; then
    cat >&2 <<EOF

Cherry-pick stopped on a conflict (rerere may have pre-resolved part of it).
  1. Fix the conflicted files, then: git add <files> && git cherry-pick --continue
  2. Or drop the commit:            git cherry-pick --skip
  3. Or give up:                    git cherry-pick --abort && git switch $port_branch && git branch -D $release_branch
When the cherry-pick finishes, continue with the build and release steps below by hand.
EOF
    print_next_steps "$new_tag" "$release_branch" "$port_branch"
    exit 1
  fi

  git submodule update --init --recursive

  if [[ "${SKIP_BUILD:-0}" != "1" ]]; then
    pio run -e ws397-gh_release
  fi

  print_next_steps "$new_tag" "$release_branch" "$port_branch"
}

print_next_steps() {
  local new_tag="$1" release_branch="$2" port_branch="$3"
  cat <<EOF

Next steps:
  pio run -e ws397-gh_release                     # if not built above
  # test on hardware
  git branch -f $port_branch $release_branch
  git tag $new_tag-ws397 $release_branch
  git push --force-with-lease origin $port_branch $release_branch
  git push origin $new_tag-ws397
  # publish the GitHub release with .pio/build/ws397-gh_release/firmware.bin
EOF
}

# Parse the whole file before running: the checkout below may replace this script on disk.
main "$@"
exit
