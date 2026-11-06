#!/bin/zsh
# 从 Swift 源码提取可本地化文案，并与简体中文目录比对。
# 传入 --write 时把缺失的 key 以英文占位追加到目录，等待翻译。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/compositor-localizations.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

PYTHON="${PYTHON:-/usr/bin/python3}"
if [[ ! -x "$PYTHON" ]]; then
  PYTHON=python3
fi

files=("$ROOT"/Compositor/**/*.swift)
xcrun xcstringstool extract --SwiftUI --legacy-localizable-strings \
  --output-directory "$TMP" --output-format strings "${files[@]}" >/dev/null

args=(--source "$ROOT" --extracted "$TMP")
[[ "${1:-}" == --write ]] && args+=(--write)
"$PYTHON" "$ROOT/scripts/check-localizations.py" "${args[@]}"
