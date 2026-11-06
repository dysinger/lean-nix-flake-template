#!/usr/bin/env bash
# Verify the template's zero-`sorry` gate is load-bearing.
#
# The template's README claims a build that encounters a `sorry` fails
# (`README.md:8`, `:50`), and `lakefile.lean` makes that true with
# `moreLeanArgs := #["-DwarningAsError=true"]`. A claim about a gate is only
# worth what its falsification costs, so this script *stubs a `sorry` and
# expects the build to fail*, then restores the file.
#
# Run from the template root:  ./scripts/verify-sorry-gate.sh
#
# Exits 0 when the gate fires (build fails on the stub AND is green again after
# restore), 1 otherwise. It is deliberately not a `checks` entry: it mutates a
# source file, so it is a manual/CI-verification tool, not a build step.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/Example/Count.lean"
BACKUP="$(mktemp)"
trap 'cp "$BACKUP" "$TARGET"; rm -f "$BACKUP"' EXIT

cp "$TARGET" "$BACKUP"

# 1. The gate must be present at all. Without the flag a `sorry` only warns.
if ! grep -q 'DwarningAsError=true' "$ROOT/lakefile.lean"; then
  echo "FAIL: lakefile.lean has no moreLeanArgs with -DwarningAsError=true" >&2
  echo "      the zero-sorry claim in README.md:8/:50 is false" >&2
  exit 1
fi

# 2. Stub a theorem and require the build to fail.
printf '\ntheorem sorryGateProbe : 1 = 1 := sorry\n' >> "$TARGET"
if (cd "$ROOT" && lake build >/dev/null 2>&1); then
  echo "FAIL: build succeeded with a stubbed 'sorry' — the gate is not enforced" >&2
  exit 1
fi

# 3. Restore and require green again, so this script cannot leave the tree red.
cp "$BACKUP" "$TARGET"
if ! (cd "$ROOT" && lake build >/dev/null 2>&1); then
  echo "FAIL: build is not green after restoring $TARGET" >&2
  exit 1
fi

echo "OK: the zero-sorry gate is load-bearing (stub fails the build; restore is green)"
