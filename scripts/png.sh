#!/usr/bin/env bash
# Render slides to PNG for visual review (by you or an agent):
#   build/png/<talk>/NN.png  — one per page (handout mode, i.e. final states)
#   build/png/<talk>/sheet.png — contact sheet of the whole deck
# Usage: scripts/png.sh <talk> [ppi]     (default ppi 80)
source "$(dirname "$0")/_env.sh"
dir="$(talk_dir "${1:?usage: scripts/png.sh <talk> [ppi]}")"; name="$(basename "$dir")"
ppi="${2:-80}"
out="$BUILD/png/$name"; rm -rf "$out"; mkdir -p "$out"
typst compile "${TYPST_FLAGS[@]}" --input handout=true --ppi "$ppi" "$dir/slides.typ" "$out/{0p}.png"
files="$(cd "$out" && ls [0-9]*.png | sed "s|^|/build/png/$name/|" | paste -sd, -)"
typst compile "${TYPST_FLAGS[@]}" --input files="$files" --ppi 72 "$ROOT/scripts/sheet.typ" "$out/sheet.png"
echo "✓ $(ls "$out"/[0-9]*.png | wc -l | tr -d ' ') slides → build/png/$name/  (overview: build/png/$name/sheet.png)"
