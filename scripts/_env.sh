# Shared settings for scripts/*.sh — sourced, not executed.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TYPST_FLAGS=(--root "$ROOT" --font-path "$ROOT/fonts")
BUILD="$ROOT/build"

# talk_dir <name|path> → absolute talk directory
talk_dir() {
  local t="${1%/}"
  if [[ -f "$t/slides.typ" ]]; then (cd "$t" && pwd)
  elif [[ -f "$ROOT/talks/$t/slides.typ" ]]; then echo "$ROOT/talks/$t"
  else echo "error: no talk '$1' (expected talks/$1/slides.typ)" >&2; exit 1
  fi
}

all_talks() {
  for d in "$ROOT"/talks/*/; do
    local n="$(basename "$d")"
    [[ "$n" == _* ]] && continue
    [[ -f "$d/slides.typ" ]] && echo "$n"
  done
}
