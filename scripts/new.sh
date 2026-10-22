#!/usr/bin/env bash
# Start a new talk from talks/_template: scripts/new.sh 2026-11-aaai-fever
source "$(dirname "$0")/_env.sh"
name="${1:?usage: scripts/new.sh <yyyy-mm-venue-topic>}"
dest="$ROOT/talks/$name"
[[ -e "$dest" ]] && { echo "error: talks/$name exists" >&2; exit 1; }
cp -r "$ROOT/talks/_template" "$dest"
echo "✓ talks/$name — edit talks/$name/slides.typ, then: scripts/watch.sh $name"
