#!/bin/sh
set -eu
REPO="${1:?Usage: verify-ci-status.sh <owner/repo> <sha>}"
SHA="${2:?Usage: verify-ci-status.sh <owner/repo> <sha>}"

conclusions=$(gh api "repos/${REPO}/commits/${SHA}/check-runs" --jq '.check_runs[] | select(.name=="test") | .conclusion')

if [ -z "$conclusions" ]; then
  echo "::error::No 'test' check run found for commit ${SHA}. Refusing to release a commit that has not cleared CI." >&2
  exit 1
fi

for conclusion in $conclusions; do
  if [ "$conclusion" != "success" ]; then
    echo "::error::The 'test' check run for commit ${SHA} has not succeeded (conclusion: ${conclusion}). Refusing to release." >&2
    exit 1
  fi
done

echo "CI check 'test' passed for commit ${SHA}."
