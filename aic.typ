// AIC — a Touying theme for scientific talks, styled after the
// AI Center FEE CTU slide deck (navy title slide, light content slides,
// purple accent, Epilogue typeface).
//
// Usage (from talks/<name>/slides.typ, compiled with `--root .`):
//
//   #import "/aic.typ": *
//   #show: aic-theme.with(
//     venue: [FEVER Workshop \@ EACL 2026 · Rabat],
//     config-info(title: [...], author: [...], date: datetime.today()),
//   )
//   #title-slide()
//   = Section
//   == Slide title
//   Content…

#import "@preview/touying:0.8.0": *
#import "@preview/tiaoma:0.3.0"

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------

#let aic = (
  navy: rgb("#001838"), // ink + dark backgrounds
  paper: rgb("#F3F6F9"), // content slide background
  purple: rgb("#7453F8"), // primary accent (logomark colour)
  blue: rgb("#4353FF"), // web brand blue
  slate: rgb("#3E516A"),
  muted: rgb("#6A7D96"), // secondary text
  line: rgb("#D5DCE5"), // hairlines, borders
  tint: rgb("#E9E5FE"), // light purple fill
  orange: rgb("#FF8731"),
  coral: rgb("#F26B43"),
  pink: rgb("#CF6FDB"),
  teal: rgb("#2BB596"), // darkened #4ED9B8 so it reads on light paper
  lime: rgb("#D6FF31"), // dark backgrounds only
  green: rgb("#1F9D55"),
  red: rgb("#D93025"),
)

// Decorative network graph from the AIC deck (top-right corner), as vectors.
#let _net-nodes = ((197, 2), (147, 15), (175, 22), (190, 27), (257, 43), (153, 42), (67, 29), (44, 83), (108, 83), (170, 119), (306, 130), (83, 170), (49, 191), (136, 215), (2, 227), (93, 254))
#let _net-edges = ((0, 1), (0, 4), (0, 3), (0, 9), (1, 2), (2, 3), (3, 4), (1, 6), (1, 5), (5, 8), (5, 9), (4, 9), (6, 8), (6, 7), (7, 8), (7, 11), (7, 12), (7, 14), (8, 11), (8, 9), (9, 10), (9, 11), (9, 13), (11, 13), (11, 12), (12, 14), (14, 15), (13, 15))
#let _network(scale: 0.5, color: rgb("#C9D2DD")) = box(width: 310pt * scale, height: 258pt * scale, {
  let p(i) = (_net-nodes.at(i).at(0) * scale * 1pt, _net-nodes.at(i).at(1) * scale * 1pt)
  for (a, b) in _net-edges { place(line(start: p(a), end: p(b), stroke: 0.5pt + color)) }
  for (i, _) in _net-nodes.enumerate() {
    let (x, y) = p(i)
    place(dx: x - 1.6pt, dy: y - 1.6pt, circle(radius: 1.6pt, fill: rgb("#24344F")))
  }
})

// Geometry of the 16:9 page (841.89pt × 473.56pt), shared with helpers that
// need to escape the content area (e.g. `bleed-right`).
#let _mx = 34pt // left/right margin
#let _mt = 74pt // top margin (title lives above)
#let _mb = 34pt // bottom margin (footer lives below)

#let _asset(name) = "/assets/" + name
#let _section = counter("aic-section")

// Overflow detector. Each slide body starts with an <aic-slide-start>
// marker; a content page without one is a spill-over created by content that
// did not fit. It gets a red badge and an <aic-overflow> metadata entry
// (listed by `scripts/check.sh`).
#let _overflow-guard = context {
  let page = here().page()
  let starts = query(<aic-slide-start>).filter(m => m.location().page() == page)
  if starts.len() == 0 {
    [#metadata(page) <aic-overflow>]
    place(top + center, dy: 4pt, box(
      fill: aic.red,
      inset: (x: 8pt, y: 4pt),
      radius: 3pt,
      text(size: 10pt, fill: white, weight: "bold")[OVERFLOW — previous slide spilled onto this page],
    ))
  }
}

// ---------------------------------------------------------------------------
// Slides
// ---------------------------------------------------------------------------

/// Regular content slide. Normally created implicitly by `== Title`.
#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto { self.store.align = align }
  let header(self) = {
    set std.align(top)
    _overflow-guard
    if self.store.decor { place(top + right, dx: 6pt, dy: -8pt, _network(scale: 0.42)) }
    pad(x: _mx, top: 26pt, grid(
      columns: (1fr, auto),
      gutter: 16pt,
      {
        set text(size: 26pt, weight: "semibold", fill: self.colors.neutral-darkest)
        set par(leading: 0.35em)
        if title != auto {
          utils.fit-to-width(grow: false, 100%, title)
        } else {
          utils.display-current-heading(
            depth: self.slide-level,
            setting: utils.fit-to-width.with(grow: false, 100%),
          )
        }
      },
      if self.store.logo { image(_asset("aic-mark-purple.svg"), height: 22pt) },
    ))
  }
  let footer(self) = {
    set std.align(bottom)
    set text(size: 10pt, fill: self.colors.neutral)
    pad(x: _mx, bottom: 12pt, grid(
      columns: (auto, 1fr, auto),
      gutter: 12pt,
      context utils.slide-counter.display() + " of " + utils.last-slide-number,
      [],
      utils.call-or-display(self, self.store.footer),
    ))
    if self.store.progress {
      place(bottom + left, components.progress-bar(
        height: 3pt,
        self.colors.primary,
        self.colors.neutral-lightest,
      ))
    }
  }
  let self = utils.merge-dicts(self, config-page(
    fill: self.colors.neutral-lightest,
    header: header,
    footer: footer,
  ))
  let new-setting = body => {
    [#metadata(none) <aic-slide-start>]
    show: std.align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

// Dark slide with the AIC wave background (title / closing slides).
#let _dark-page(self) = config-page(
  fill: self.colors.secondary,
  margin: 0pt,
  header: none,
  footer: none,
  background: image(_asset("title-bg.jpg"), width: 100%, height: 100%, fit: "cover"),
)

/// Title slide. Reads `config-info(...)` and the theme's `venue`.
/// Any field can be overridden: `#title-slide(subtitle: [...])`.
/// `qr`: URL rendered as a QR code bottom-right (slides PDF, paper, repo…).
#let title-slide(config: (:), qr: none, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    _dark-page(self),
    config,
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: white)
    // venue / date, top-right like the AIC deck
    place(top + right, dx: -_mx, dy: 34pt, block(width: 55%, std.align(right, text(
      size: 15pt,
      {
        utils.call-or-display(self, self.store.venue)
        if info.date != none {
          if self.store.venue != none [ · ]
          utils.display-info-date(self)
        }
      },
    ))))
    place(top + left, dx: _mx, dy: 128pt, block(width: 100% - 2 * _mx, {
      set par(leading: 0.3em)
      text(size: 38pt, weight: "semibold", info.title)
      if info.subtitle != none {
        v(14pt)
        text(size: 22pt, weight: "regular", fill: self.colors.primary-light, info.subtitle)
      }
    }))
    place(bottom + left, dx: _mx, dy: -34pt, block(width: 80%, {
      if info.author != none {
        text(size: 19pt, weight: "medium", info.author)
      }
      if info.institution != none {
        v(6pt)
        text(size: 13pt, fill: white.transparentize(25%), info.institution)
      }
      if info.contact != none {
        v(4pt)
        text(size: 13pt, fill: white.transparentize(25%), info.contact)
      }
    }))
    if qr != none {
      place(bottom + right, dx: -_mx, dy: -34pt, box(
        fill: white,
        inset: 5pt,
        radius: 4pt,
        tiaoma.qrcode(qr, width: 66pt),
      ))
    }
  }
  touying-slide(self: self, body)
})

/// Section divider. Created implicitly by `= Section`.
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-page(
    fill: self.colors.secondary,
    margin: (x: _mx * 2, y: 0pt),
    header: none,
    footer: none,
  ))
  let setting(body) = {
    set std.align(horizon)
    set text(fill: white)
    _section.step()
    context {
      let n = _section.get().first()
      text(size: 64pt, weight: "bold", fill: self.colors.primary, if n < 10 { "0" } + str(n))
    }
    v(-8pt)
    text(size: 36pt, weight: "semibold", utils.display-current-heading(level: level, numbered: false))
    v(10pt)
    block(width: 40%, components.progress-bar(
      height: 3pt,
      self.colors.primary,
      self.colors.slate,
    ))
    if body != none { text(size: 18pt, fill: white.transparentize(30%), body) }
    place(bottom + right, dy: -28pt, image(_asset("aic-logo-white.svg"), height: 22pt))
  }
  touying-slide(self: self, config: config, setting: setting, body)
})

/// One big statement on a purple slide: `#focus-slide[Wait — that's 3rd place?]`
#let focus-slide(config: (:), align: horizon + center, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 3em, header: none, footer: none),
    config,
  )
  touying-slide(
    self: self,
    setting: it => std.align(align, text(fill: white, size: 34pt, weight: "semibold", it)),
    body,
  )
})

/// Closing slide on the dark background: `#end-slide(qr: "https://...")[contacts]`
#let end-slide(config: (:), title: [Thank you!], qr: none, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    _dark-page(self),
    config,
  )
  let content = {
    set text(fill: white)
    place(top + left, dx: _mx, dy: 150pt, block(width: 100% - 2 * _mx, {
      text(size: 44pt, weight: "semibold", title)
      v(18pt)
      set text(size: 18pt)
      body
    }))
    if qr != none {
      place(bottom + right, dx: -_mx, dy: -34pt, stack(
        spacing: 6pt,
        box(fill: white, inset: 6pt, radius: 4pt, tiaoma.qrcode(qr, width: 100pt)),
        std.align(center, text(size: 10pt, fill: white.transparentize(30%), qr.replace(regex("^https?://"), ""))),
      ))
    }
  }
  touying-slide(self: self, content)
})

/// Speaker-note panel (used with `config-common(show-notes-on-second-screen: right)`).
#let notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 32pt, y: 16pt, text(fill: white, utils.display-current-heading(depth: self.slide-level))),
  header-fill: self.colors.secondary,
  fill: self.colors.neutral-lightest,
  ..args,
)

// ---------------------------------------------------------------------------
// Theme entry point
// ---------------------------------------------------------------------------

/// - venue (content): Shown top-right on the title slide, e.g. `[FEVER \@ EACL 2026]`.
/// - footer (content, function): Footer right part. Default: short title.
/// - progress (bool): Thin purple progress bar at the bottom of content slides.
/// - logo (bool): Purple AIC mark in the top-right corner of content slides.
/// - decor (bool): Faint network-graph ornament behind the mark.
/// - paper (color): Content slide background (`white` prints cleaner).
/// - handout: `auto` reads `--input handout=true` from the CLI. In handout mode
///   every `#pause` sequence collapses into its final state — use it for the
///   PDF you email / upload.
#let aic-theme(
  aspect-ratio: "16-9",
  align: top,
  venue: none,
  footer: self => self.info.short-title,
  progress: true,
  logo: true,
  decor: true,
  paper: aic.paper,
  handout: auto,
  ..args,
  body,
) = {
  let handout = if handout == auto {
    sys.inputs.at("handout", default: "false") == "true"
  } else { handout }

  set text(font: "Epilogue", size: 18pt, weight: "regular", fill: aic.navy, lang: "en")
  set par(leading: 0.6em, spacing: 1.0em)
  set strong(delta: 200)
  set list(marker: ([#text(fill: aic.purple, size: 1.1em)[•]], [#text(fill: aic.muted)[–]]), indent: 0.2em, body-indent: 0.55em, spacing: 0.75em)
  set enum(numbering: n => text(fill: aic.purple, weight: "semibold", str(n) + "."), spacing: 0.75em)
  show link: set text(fill: aic.purple)
  show raw: set text(font: "DejaVu Sans Mono", size: 0.85em)
  show raw.where(block: true): block.with(fill: white, stroke: 0.6pt + aic.line, inset: 10pt, radius: 4pt, width: 100%)
  show footnote.entry: set text(size: 10pt, fill: aic.muted)
  set footnote.entry(separator: line(length: 15%, stroke: 0.5pt + aic.line), clearance: 0.6em, gap: 0.3em)
  // booktabs-like tables: rule under header, no grid
  set table(
    stroke: (x, y) => if y == 0 { (top: 1pt + aic.navy, bottom: 0.6pt + aic.navy) } else { none },
    inset: (x: 8pt, y: 5pt),
    align: (x, y) => if x == 0 { left } else { center },
  )
  show table.cell.where(y: 0): set text(weight: "semibold")
  show table: it => block(stroke: (bottom: 1pt + aic.navy), it)
  show figure.caption: set text(size: 12pt, fill: aic.muted)
  set figure(gap: 6pt)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      header-ascent: 0pt,
      footer-descent: 0pt,
      margin: (top: _mt, bottom: _mb + 6pt, x: _mx),
    ),
    config-common(
      slide-fn: slide,
      notes-fn: notes,
      new-section-slide-fn: new-section-slide,
      show-bibliography-as-footnote: true,
      handout: handout,
      zero-margin-header: true,
      zero-margin-footer: true,
    ),
    config-methods(
      alert: (self: none, it) => text(fill: self.colors.primary, weight: "semibold", it),
      cover: utils.alpha-changing-cover,
    ),
    config-colors(
      primary: aic.purple,
      primary-light: rgb("#B9A9FF"),
      secondary: aic.navy,
      neutral: aic.muted,
      neutral-lightest: paper,
      neutral-darkest: aic.navy,
      slate: aic.slate,
    ),
    config-store(
      align: align,
      venue: venue,
      footer: footer,
      progress: progress,
      logo: logo,
      decor: decor,
    ),
    ..args,
  )
  body
}

// ---------------------------------------------------------------------------
// Helpers — the "utilitarian" layer. All are plain functions; mix freely.
// ---------------------------------------------------------------------------

/// Purple highlight — works anywhere, including slide titles:
///   == Our system: #hl[dual-retriever RAG]
#let hl(body) = text(fill: aic.purple, body)

/// Secondary / de-emphasised text.
#let muted(body) = text(fill: aic.muted, body)
#let small(body) = text(size: 0.8em, body)

/// Columns: `#cols[left][right]`, `#cols(columns: (2fr, 1fr))[a][b]`.
#let cols(columns: auto, gutter: 24pt, align: top, ..bodies) = {
  let bodies = bodies.pos()
  let columns = if columns == auto { (1fr,) * bodies.len() } else { columns }
  grid(columns: columns, column-gutter: gutter, align: align, ..bodies)
}

/// Image with optional caption and source line. `path` is relative to the
/// calling file, so pass `image("figures/x.png")` OR a path string resolved
/// via `read`… simplest: pass the image itself:
///   #fig(image("figures/pipeline.pdf", width: 100%), caption: [Pipeline])
#let fig(body, caption: none, source: none) = {
  set std.align(center)
  block({
    body
    if caption != none or source != none {
      v(4pt, weak: true)
      set text(size: 12pt, fill: aic.muted)
      caption
      if caption != none and source != none [ · ]
      if source != none { emph(source) }
    }
  })
}

/// Framed screenshot: thin border, rounded corners, optional source line.
///   #screenshot(image("figures/paste-2026-10-22.png", width: 80%), source: [arxiv.org/abs/…])
#let screenshot(body, source: none, radius: 6pt) = {
  set std.align(center)
  block({
    box(
      stroke: 0.8pt + aic.line,
      radius: radius,
      clip: true,
      body,
    )
    if source != none {
      v(4pt, weak: true)
      text(size: 11pt, fill: aic.muted, emph(source))
    }
  })
}

/// Image glued to the right edge of the slide (AIC deck style), spanning the
/// content area's height; text flows in the remaining width on the left.
///   #bleed-right(image("figures/x.jpg"), width: 36%)[ text … ]
/// `width` is a fraction of the page width. Image is cropped to fill (`fit: "cover"`).
#let bleed-right(img, width: 36%, fit: "cover", body) = layout(size => {
  let page-w = size.width + 2 * _mx
  let w = if type(width) == ratio { page-w * width } else { width }
  place(top + right, dx: _mx, box(width: w, height: size.height, clip: true, {
    set image(width: 100%, height: 100%, fit: fit)
    img
  }))
  block(width: size.width - w + _mx - 24pt, body)
})

/// Take-home message box (purple bar on the left).
#let takeaway(title: none, body) = block(
  width: 100%,
  fill: aic.tint,
  stroke: (left: 4pt + aic.purple),
  inset: (x: 14pt, y: 10pt),
  radius: (right: 4pt),
  {
    if title != none { text(weight: "semibold", fill: aic.purple, title); linebreak() }
    body
  },
)

/// Neutral box, e.g. for definitions or examples. `color` tints the border.
#let box-note(title: none, color: aic.navy, body) = block(
  width: 100%,
  fill: white,
  stroke: 0.8pt + color.lighten(60%),
  inset: (x: 14pt, y: 10pt),
  radius: 4pt,
  {
    if title != none { text(weight: "semibold", fill: color, title); linebreak() }
    body
  },
)

/// Label chip: `#pill[Refuted]`, `#pill(color: aic.green)[Supported]`.
#let pill(color: aic.purple, body) = box(
  fill: color.lighten(85%),
  stroke: 0.6pt + color,
  inset: (x: 6pt, y: 0pt),
  outset: (y: 3pt),
  radius: 99pt,
  text(size: 0.8em, weight: "medium", fill: color.darken(15%), body),
)

/// Big-number tile for results: `#stat[3rd][place in AVerImaTeC]`.
#let stat(color: aic.purple, value, label) = block(
  width: 100%,
  inset: (x: 14pt, y: 12pt),
  radius: 6pt,
  fill: white,
  stroke: 0.6pt + aic.line,
  {
    text(size: 34pt, weight: "bold", fill: color, value)
    linebreak()
    text(size: 13pt, fill: aic.slate, label)
  },
)

/// Best value in a results table.
#let best(body) = text(weight: "bold", fill: aic.purple, body)

/// Small source / attribution line pinned to the bottom-right of the content area.
#let source(body) = place(bottom + right, dy: 6pt, text(size: 10pt, fill: aic.muted, body))

/// Absolute placement within the content area: `#at(60%, 40%)[...]`.
/// Use for annotations, arrows, overlays — full control when needed.
#let at(x, y, body) = place(top + left, dx: x, dy: y, body)

/// Visible placeholder for things still to do. `scripts/check.sh` lists them.
#let todo(body) = box(
  fill: aic.red.lighten(85%),
  stroke: 0.8pt + aic.red,
  inset: (x: 5pt, y: 2pt),
  radius: 3pt,
  text(size: 0.75em, fill: aic.red, weight: "semibold")[TODO: #body],
)

/// QR code (via tiaoma) — e.g. link to slides / paper on any slide.
#let qr(url, width: 80pt) = tiaoma.qrcode(url, width: width)
