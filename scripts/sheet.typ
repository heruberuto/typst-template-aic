// Contact sheet: all slide PNGs in one image. Driven by scripts/png.sh.
#let files = sys.inputs.files.split(",")
#set page(width: auto, height: auto, margin: 8pt, fill: rgb("#8A94A3"))
#set text(size: 9pt, fill: white, font: "DejaVu Sans Mono")
#grid(
  columns: 4,
  gutter: 8pt,
  ..files.enumerate().map(((i, f)) => stack(spacing: 2pt, image(f, width: 300pt), str(i + 1))),
)
