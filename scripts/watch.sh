#!/usr/bin/env bash
# Recompile on every save: scripts/watch.sh <talk>  → build/<talk>.pdf
# (In VS Code, Tinymist's live preview is nicer: "Typst Preview" on slides.typ.)
source "$(dirname "$0")/_env.sh"
dir="$(talk_dir "${1:?usage: scripts/watch.sh <talk>}")"; name="$(basename "$dir")"
mkdir -p "$BUILD"
exec typst watch "${TYPST_FLAGS[@]}" "$dir/slides.typ" "$BUILD/$name.pdf"
