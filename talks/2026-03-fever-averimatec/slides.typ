// Example deck: re-creation of the FEVER @ EACL 2026 AVerImaTeC talk.
// Doubles as a feature showcase — every helper from /aic.typ is used once.
#import "/aic.typ": *

#show: aic-theme.with(
  venue: [9th FEVER Workshop \@ EACL'26],
  config-info(
    title: [AIC\@CTU System at AVerImaTeC],
    short-title: [AIC\@CTU at AVerImaTeC],
    subtitle: [Dual-retriever RAG for image-text fact checking],
    author: [*Herbert Ullrich*, Jan Drchal],
    institution: [Artificial Intelligence Center · Faculty of Electrical Engineering · Czech Technical University in Prague],
    date: datetime(year: 2026, month: 3, day: 28),
  ),
  config-common(datetime-format: "[month repr:long] [day padding:none], [year]"),
)

#title-slide(qr: "https://aclanthology.org/2026.fever-1.11/")

= The task

== Our challenge: #hl[AVerImaTeC]

#cols(columns: (1fr, 1.1fr))[
  - Image-text claims from real fact-checks @cao-etal-2025-averimatec
  - Size (train/dev/test): 793 / 152 / 352
  - Labels: #pill(color: aic.red)[Refuted] #pill(color: aic.green)[Supported] #pill(color: aic.muted)[NEI] #pill(color: aic.orange)[Conflicting]
  - Output: QA pairs as evidence + verdict + justification
  #pause
  #takeaway(title: [Twist])[Evidence can be *text and images* — retrieval must handle both.]
][
  #screenshot(image("figures/datapoint.png", height: 78%), source: [AVerImaTeC dev set])
]

#speaker-note[Mention 1.3K claims overall; same Q/A evidence format as AVeriTeC.]

= Our system

== Our system: #hl[dual-retriever RAG]

#fig(image("figures/pipeline.svg", width: 92%))

- Extended from our previous years' AVeriTeC systems, now in 3 modules:
  #hl[i. text retriever], #hl[ii. image retriever (RIS)], #hl[iii. generation]
- A single multimodal LLM call + a single reverse-image-search request per claim

== i. Text-based retrieval

#bleed-right(image("figures/retriever.png"), width: 30%, fit: "contain")[
  1. Embed claim + documents with `mxbai-embed-large-v1`@lee-etal-2024-open
  2. Chunk documents to *2048* characters to fill the encoder input
  3. KNN retrieval from a Faiss vector store
  4. MMR re-ranking for diverse sources

  #v(10pt)
  #box-note(title: [Why MMR?])[
    Plain KNN returns near-duplicates; MMR trades relevance for diversity:
    $ "MMR" = arg max_(d in R without S) [lambda "sim"(d, q) - (1 - lambda) max_(s in S) "sim"(d, s)] $
  ]
]

== ii. Image-based retrieval

#cols(columns: (1fr, 1fr), align: horizon)[
  #fig(image("figures/facticli-pipeline.pdf", height: 80%), caption: [PDF figures embed as vectors], source: [dissertation])
][
  - Google Lens (RIS) → Firecrawl scraping → date filtering
  - Up to *30* results per image, first *9* kept
  - Post-claim results removed #todo[cite Firecrawl]
]

= Results

== System #hl[performance]

#cols(columns: (1.8fr, 1fr))[
  #table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    [System], [Q], [Evidence], [Verdict], [Justif.],
    [HUMANE], best[0.89], best[0.54], best[0.55], best[0.56],
    [ADA-AGGR], [0.37], [0.46], [0.54], [0.43],
    [*AIC CTU (ours)*], [0.81], [0.33], [0.35], [0.30],
    [XxP], [0.39], [0.27], [0.26], [0.20],
    [REVEAL], [0.63], [0.28], [0.24], [0.13],
    [Baseline], [0.55], [0.17], [0.11], [0.13],
  )
][
  #stat[3rd][place out of 7 teams]
  #v(8pt)
  #stat(color: aic.teal)[~\$0.01][per claim with GPT-5.1 \ (+ \$0.003 per RIS image)]
]
#source[Scores from the shared-task overview @cao-etal-2026-automatic]

#focus-slide[Simple RAG gets you to #text(fill: aic.lime)[3rd place] \ at one cent per claim.]

== Key finding

#takeaway(title: [Key finding])[
  A dual-retriever RAG scores *3rd place* at AVerImaTeC with *1 prompt* and ~\$0.02 per claim.
]

*Future work*
- More robust RIS (Google Lens pitfalls with older / explicit claims)
- Agentic extension: LLM controller decides when to use RIS
- Fix the image-evidence format mismatch with the evaluator

#at(80%, 52%)[#align(center)[#qr("https://aclanthology.org/2026.fever-1.11/", width: 80pt) \ #small[Paper]]]

== References

#set text(size: 12pt)
#bibliography("refs.bib", title: none, style: "apa")

#end-slide(qr: "https://aclanthology.org/2026.fever-1.11/")[
  Herbert Ullrich · #link("mailto:ullriher@fel.cvut.cz")[ullriher\@fel.cvut.cz] \
  #muted[AI Center, FEE CTU in Prague]
]
