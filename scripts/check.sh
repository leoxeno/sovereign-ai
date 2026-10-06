#!/usr/bin/env bash
# The canonical gate. Humans, agents, hooks and CI all run this.
# Usage: ./scripts/check.sh [--fast]   (--fast skips the Tauri bundle; the bundle only builds on a Windows host)
# Steps whose tooling does not exist yet (no package.json, no src-tauri/) are reported as skipped, not failed,
# so the gate is runnable from the first commit. Once the tooling exists, the step is mandatory.
set -euo pipefail
cd "$(dirname "$0")/.."

FAST=0
[[ "${1:-}" == "--fast" ]] && FAST=1

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
skip() { printf 'skipped: %s\n' "$1"; }

step "AGENTS.md mirrors CLAUDE.md"
if ! cmp -s CLAUDE.md AGENTS.md; then
  echo "AGENTS.md and CLAUDE.md differ. AGENTS.md must be a symlink to CLAUDE.md (ln -sfn CLAUDE.md AGENTS.md)." >&2
  exit 1
fi
echo "ok"

step "privacy scan"
# Generic patterns live here. Owner-specific patterns live in an untracked .privacy-patterns file (one regex per line).
PATTERNS='gmail\.com|hotmail\.com|outlook\.com|C:\\Users\\|/mnt/c/Users/|users\.noreply\.github\.com'
if [[ -f .privacy-patterns ]]; then
  PATTERNS="$PATTERNS|$(grep -v '^\s*#' .privacy-patterns | grep -v '^\s*$' | paste -sd '|' -)"
fi
if grep -rniIE "$PATTERNS" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=target \
    --exclude-dir=.specstory --exclude=.privacy-patterns --exclude=check.sh --exclude=setup-dev.sh . ; then
  echo "Privacy scan matched. Remove the identifier before committing." >&2
  exit 1
fi
echo "clean"

step "no model weights or engine binaries in the tree"
if find . -path ./node_modules -prune -o -path ./target -prune -o -path ./.git -prune -o \
    \( -iname '*.gguf' -o -iname 'llama-server*' -o -iname '*.safetensors' \) -print | grep -q .; then
  echo "Weights or engine binaries found in the tree. They are downloaded at run time, never committed (non-negotiables 1 and 9)." >&2
  exit 1
fi
echo "clean"

step "spec index"
for f in docs/specs/[0-9][0-9][0-9]-*.md; do
  [[ -e "$f" ]] || continue
  n=$(basename "$f")
  if ! grep -q "$n" docs/specs/README.md; then
    echo "$n is not listed in docs/specs/README.md." >&2
    exit 1
  fi
done
echo "ok"

step "frontend: lint, typecheck, test"
if [[ -f package.json ]]; then
  npm run --silent lint
  npm run --silent typecheck
  npm test --silent
else
  skip "no package.json yet; spec 001 creates it"
fi

step "rust: fmt, clippy, test"
if [[ -f src-tauri/Cargo.toml ]]; then
  if ! command -v cargo >/dev/null 2>&1; then
    echo "cargo not found. Install the Rust toolchain (rustup) on this clone or run the gate on the Windows clone." >&2
    exit 1
  fi
  cargo fmt --manifest-path src-tauri/Cargo.toml --all -- --check
  cargo clippy --manifest-path src-tauri/Cargo.toml --all-targets -- -D warnings
  cargo test --manifest-path src-tauri/Cargo.toml
else
  skip "no src-tauri/ yet; spec 001 creates it"
fi

if [[ $FAST -eq 0 ]]; then
  step "tauri bundle"
  if [[ ! -f src-tauri/Cargo.toml ]]; then
    skip "no src-tauri/ yet"
  else
    host=$(rustc --print host-tuple 2>/dev/null || true)
    if [[ "$host" == *windows* ]]; then
      npm run --silent tauri build
    else
      skip "the bundle is built on a Windows host (this host is ${host:-unknown}); CI's windows job covers it"
    fi
  fi
fi

printf '\n\033[32mcheck.sh: all green\033[0m\n'
