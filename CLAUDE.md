# CLAUDE.md

Guidance for coding agents working in this repository. `AGENTS.md` is a symlink to this file.

## Project Snapshot

- Type: personal slide-deck template for scientific talks — **Typst 0.15 + Touying 0.8.0**
- Theme: `aic.typ`, styled after the AI Center FEE CTU deck (navy title slide, light content slides, purple `#7453F8` accent, Epilogue font)
- One repo, many talks: each talk is `talks/<yyyy-mm-venue-topic>/slides.typ` with its own `figures/` and `refs.bib`
- `talks/_template/` is the skeleton copied by `scripts/new.sh`; `talks/2026-03-fever-averimatec/` is a full example that uses every helper — read it before writing a new deck

## Commands

All scripts compile with `--root <repo> --font-path fonts`, so `/aic.typ` and `/assets/...` resolve from the repo root.

```bash
scripts/new.sh 2026-11-venue-topic     # copy talks/_template → talks/<name>
scripts/watch.sh <talk>                # live recompile → build/<talk>.pdf
scripts/build.sh [talk ...]            # build/<talk>.pdf + build/<talk>-handout.pdf (all talks if none given)
scripts/png.sh <talk> [ppi]            # build/png/<talk>/NN.png + sheet.png (contact sheet of the whole deck)
scripts/check.sh <talk>                # overflow detection + open #todo list; exit 1 on overflow
```

- `<talk>` is a directory name under `talks/` or a path.
- `build/` is gitignored. CI (`.github/workflows/build.yml`) builds every talk and publishes the PDFs to GitHub Pages.
- **Handout** (`--input handout=true`) collapses every `#pause` animation to its final state. The handout PDF is the one to email to attendees or upload to the conference page.

## Workflow for creating or editing a deck

1. `scripts/new.sh <name>`. Then write `talks/<name>/slides.typ`. Source material is usually a paper (LaTeX repo or PDF): reuse its figures (PDF/SVG/PNG work directly with `image(...)`) and copy the needed BibTeX entries into the talk's `refs.bib`.
2. After every meaningful change, run `scripts/check.sh <talk>` and `scripts/png.sh <talk>`.
3. **Look at `build/png/<talk>/sheet.png`** (the whole deck in one image) and open individual `NN.png` files for slides that look off. Fix overflow, cramped layouts, tiny figures, and unbalanced columns. Repeat until `check.sh` passes and the sheet looks clean.
4. Never finish while `check.sh` reports overflow. Remaining `#todo[...]` markers are fine if the user still has to supply that content; mention them.

### Overflow

Typst does not warn when content is too tall: it silently continues on a new page. The theme marks every slide start. A content page without a marker gets a red **OVERFLOW** badge and is listed by `check.sh` (by handout page number). Fix it by shrinking figures (`height: 60%`), cutting text, splitting the slide, or using `#cols`.

### Screenshots / pasted images

- Save every image into `talks/<talk>/figures/` with a descriptive kebab-case name. Never leave files at the repo root.
- If the user pasted an image into the chat, look for it in `~/.claude/image-cache/` (newest file) and copy it from there. If you cannot find a file, ask the user to drop it into `figures/`. In VS Code with Tinymist, pasting or dragging an image into `slides.typ` also saves it next to the file.
- Use `#screenshot(image("figures/x.png", height: 60%), source: [url or venue])` for web or paper screenshots, and `#fig(...)` for own diagrams and plots.

## Typst gotchas (frequent LLM mistakes)

- `@` starts a citation and `<x>` a label: write `\@` in plain text (`AIC\@CTU`, emails). `$` starts math: write `\$0.01`. `#` starts code: write `\#` for a literal hash.
- Line break is `\` (backslash + space), not `\\`. Paragraph break = blank line.
- There are no LaTeX commands: `\textbf` → `*bold*`, `\emph` → `_emph_`, `\cite{x}` → `@x`, `\includegraphics` → `image("...")`.
- Math: `$x^2$` is inline, `$ x^2 $` (with spaces inside) is a display equation. Multi-letter names need quotes or functions: `"sim"(a, b)`, `arg max`, `lambda`.
- Image paths are relative to the `.typ` file that calls `image(...)`, so always call `image("figures/...")` in the talk's `slides.typ` and pass the result to helpers.
- Sizes: `height: 60%` is relative to the remaining content area; prefer heights for figures so they never overflow.
- Function arguments: content in `[...]`, strings in `"..."`. Trailing content blocks attach: `#cols[a][b]`.

## Touying 0.8 cheat sheet

```typst
= Section            // section divider slide (numbered 01, 02, … automatically)
== Slide title       // new content slide; `#hl[...]` inside titles colours part purple
#pause               // reveal the following content on the next subslide
#meanwhile           // back to the first subslide (parallel reveal)
#only("2-")[...]     // visible only on subslides 2+, takes no space otherwise
#uncover(2)[...]     // reserves space, visible on subslide 2
#speaker-note[...]   // presenter notes (pdfpc / second screen)
#slide(title: [Custom], align: horizon)[...]   // explicit slide, e.g. vertically centred
#slide(composer: (2fr, 1fr))[left][right]      // explicit slide with columns
```

Theme options (`aic-theme.with(...)`): `venue`, `footer` (default short-title), `progress`, `logo`, `decor` (network ornament), `paper` (content background; `white` prints cleaner), `handout` (default: `--input handout=true`), `align` (default `top`), plus any Touying `config-*`.

Speaker notes on a second screen: add `config-common(show-notes-on-second-screen: right)` to the theme call.

## Theme helpers (`aic.typ`)

| Helper | Use |
|---|---|
| `title-slide(qr: url)` | dark AIC title slide; QR bottom-right (paper / slides link) |
| `focus-slide[...]` | one big statement on purple |
| `end-slide(qr: url)[contacts]` | dark closing slide |
| `hl[...]` | purple highlight, also inside `==` titles |
| `*bold*` | rendered purple-bold (Touying alert); use sparingly for numbers and key terms |
| `cols(columns: (2fr, 1fr), gutter: 24pt, align: top)[a][b]` | columns |
| `fig(image(...), caption: [...], source: [...])` | centred figure with muted caption |
| `screenshot(image(...), source: [...])` | framed screenshot with source line |
| `bleed-right(image(...), width: 36%, fit: "cover")[text]` | image glued to the right edge, text left |
| `takeaway(title: [...])[...]` | purple key-message box |
| `box-note(title: [...], color: aic.navy)[...]` | neutral box (definitions, examples) |
| `pill(color: aic.green)[Supported]` | label chip |
| `stat(color: aic.purple)[3rd][place out of 7]` | big-number tile |
| `best[0.89]` | best value in a table |
| `source[...]` | small attribution pinned bottom-right |
| `at(x, y)[...]` | absolute placement in the content area (annotations, overlays) |
| `muted[...]`, `small[...]` | secondary text |
| `qr(url, width: 80pt)` | QR code anywhere |
| `todo[...]` | red placeholder, listed by `check.sh` |

Palette: `aic.navy`, `aic.purple`, `aic.blue`, `aic.slate`, `aic.muted`, `aic.line`, `aic.tint`, `aic.orange`, `aic.coral`, `aic.pink`, `aic.teal`, `aic.green`, `aic.red`, `aic.lime` (dark backgrounds only).

Tables follow booktabs style automatically (rules under and around the header, no grid). Use `columns: (auto, 1fr, 1fr)` for a wide first column.

Citations: `@key` renders a footnote with the full reference on that slide (`show-bibliography-as-footnote`). Every deck needs a `#bibliography("refs.bib", ...)` somewhere: on a References slide, or wrapped as `#hide(bibliography(...))`.

## Style rules for decks

- One idea per slide. At most ~6 bullets, each one line if possible. Prefer a figure over prose.
- Slide titles state the point ("Dual-retriever RAG beats text-only by 9 pts"), with `#hl[...]` on the key term.
- Every result has its source: a citation `@key` or `#source[...]`.
- Typical structure: title → motivation → task/data → method → results → takeaway → end-slide with a QR to the paper.
- Keep animations (`#pause`) rare. The handout must read well without them.

## Source map

- `aic.typ`: theme + helpers (single file, edit freely)
- `assets/`: AIC logos (`aic-logo-{navy,white,holo}.svg`, `aic-mark-purple.svg`), title background `title-bg.jpg`
- `fonts/epilogue/`: Epilogue static TTFs (OFL)
- `scripts/`: build tooling (`_env.sh` holds shared flags; `sheet.typ` renders contact sheets)
- `talks/`: one directory per talk; `_`-prefixed directories are skipped by build and CI
