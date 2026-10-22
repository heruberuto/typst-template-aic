#!/usr/bin/env bash
# Turn a repo created from this template into a single-talk repo:
# removes the example deck and preview, creates talks/<name> from _template,
# and replaces the README with a short one for the talk.
# Usage: scripts/fresh.sh <yyyy-mm-venue-topic>
source "$(dirname "$0")/_env.sh"
name="${1:?usage: scripts/fresh.sh <yyyy-mm-venue-topic>}"
rm -rf "$ROOT/talks/2026-03-fever-averimatec" "$ROOT/docs/preview.png" "$ROOT/scripts/fresh.sh"
rmdir "$ROOT/docs" 2>/dev/null || true
"$ROOT/scripts/new.sh" "$name"
repo="$(basename "$ROOT")"
owner="$(git -C "$ROOT" remote get-url origin 2>/dev/null | sed -E 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#' || true)"
cat > "$ROOT/README.md" <<MD
# $repo

Slides: [\`talks/$name/slides.typ\`](talks/$name/slides.typ) · PDF: https://${owner:-OWNER}.github.io/$repo/$name-handout.pdf

Built with [typst-template-aic](https://github.com/heruberuto/typst-template-aic). See \`CLAUDE.md\` for the workflow:

\`\`\`bash
scripts/watch.sh $name   # live PDF in build/
scripts/check.sh $name   # overflow + TODO report
scripts/png.sh $name     # PNGs + contact sheet
\`\`\`
MD
echo "✓ fresh single-talk repo — edit talks/$name/slides.typ"
