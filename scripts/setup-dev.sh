#!/usr/bin/env bash
# Run once per clone. Installs the shared git hooks, checks the author identity, and says what toolchain is missing.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh

if [[ -z "$(git config user.email || true)" || "$(git config user.email)" != *"@users.noreply.github.com" ]]; then
  echo "Set a GitHub noreply author for this repo, e.g.:"
  echo "  git config user.name 'Leo Xeno'"
  echo "  git config user.email '<id>+<login>@users.noreply.github.com'"
fi

[[ -f package.json && ! -d node_modules ]] && npm install

if ! command -v cargo >/dev/null 2>&1; then
  case "$(uname -s)" in
    Linux*)
      echo "No Rust toolchain here. This clone can run docs and the fast checks; the Rust steps need rustup:"
      echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
      echo "  sudo apt install libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf   # Tauri's Linux link deps, for clippy"
      ;;
    *)
      echo "No Rust toolchain. On Windows install rustup (MSVC host) and the Visual Studio Build Tools C++ workload; see ADR-0001."
      ;;
  esac
fi

echo "Git hooks configured. Run ./scripts/check.sh --fast to verify the tree."
