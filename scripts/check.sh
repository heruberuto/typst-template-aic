#!/usr/bin/env bash
# Pre-flight before sending a deck: compile with warnings, list #todo, report size.
# Usage: scripts/check.sh <talk>
source "$(dirname "$0")/_env.sh"
dir="$(talk_dir "${1:?usage: scripts/check.sh <talk>}")"; name="$(basename "$dir")"
mkdir -p "$BUILD"
typst compile "${TYPST_FLAGS[@]}" --input handout=true "$dir/slides.typ" "$BUILD/$name-handout.pdf"
overflow="$(typst eval "${TYPST_FLAGS[@]}" --input handout=true --in "$dir/slides.typ" 'query(<aic-overflow>).map(it => it.value)' | tr -d '()[] \n')"
if [[ -n "$overflow" ]]; then echo "✗ overflow: content spilled onto handout page(s) $overflow — shrink or split the slide before"; status=1; else echo "✓ no overflow"; fi
if grep -n '#todo' "$dir"/*.typ; then echo "⚠ open TODOs above"; else echo "✓ no TODOs"; fi
echo "  build/$name-handout.pdf ($(du -h "$BUILD/$name-handout.pdf" | cut -f1))"
exit "${status:-0}"
