#!/usr/bin/env bash
#
# FamilyHub alignment preflight — the HARD RULE's teeth.
#
# Every Claude Code prompt authored from this repo runs this FIRST — before any
# git operation or file edit — and STOPS if it fails. It guarantees a FamilyHub
# session never acts on the IndigoFlow repo (or any other), and vice versa.
#
# Bonus safety: this script lives in FamilyHub. If a FamilyHub prompt is ever
# pasted into the wrong repo, the file won't exist there — an immediate signal.
#
# Usage (as the first line of any CC prompt):
#   bash scripts/preflight.sh || exit 1

set -euo pipefail

EXPECTED="matt-reynolds-research/FamilyHub"

remote=$(git remote get-url origin 2>/dev/null || echo "")
top=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [[ "$remote" != *"$EXPECTED"* ]]; then
  echo "✋ STOP — wrong repo."
  echo "   origin   = ${remote:-<none>}"
  echo "   expected = *$EXPECTED*"
  echo "   You are likely pointed at IndigoFlow or another project. Do nothing else here —"
  echo "   no edits, commits, branches, or pushes. Reopen in ~/projects/reynolds-household/FamilyHub."
  exit 1
fi

echo "✔ FamilyHub aligned — ${top}"
echo "   origin: ${remote}   branch: ${branch}"
echo "   Reminder: plain git + gh only. Do NOT use IndigoFlow's global aliases or commands"
echo "   (savedocs / pushdocs / shuttle-docs / /hotlist-next / /arm-runner) in this repo."
