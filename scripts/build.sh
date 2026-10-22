#!/usr/bin/env bash
# Build PDFs: build/<talk>.pdf (with animations) + build/<talk>-handout.pdf
# (animations collapsed — the one to email / upload).
# Usage: scripts/build.sh [talk ...]     (no args = all talks)
source "$(dirname "$0")/_env.sh"
mkdir -p "$BUILD"
if [[ $# -gt 0 ]]; then talks=("$@"); else talks=($(all_talks)); fi  # bash 3.2-safe (macOS)
for t in "${talks[@]}"; do
  dir="$(talk_dir "$t")"; name="$(basename "$dir")"
  typst compile "${TYPST_FLAGS[@]}" "$dir/slides.typ" "$BUILD/$name.pdf"
  typst compile "${TYPST_FLAGS[@]}" --input handout=true "$dir/slides.typ" "$BUILD/$name-handout.pdf"
  echo "✓ build/$name.pdf  build/$name-handout.pdf"
done
