#import "/aic.typ": *

#show: aic-theme.with(
  venue: [Venue · City],
  config-info(
    title: [Talk title],
    short-title: [Short title],
    subtitle: [One-line subtitle],
    author: [*Herbert Ullrich*, Jan Drchal],
    institution: [Artificial Intelligence Center · FEE · Czech Technical University in Prague],
    date: datetime.today(),
  ),
  config-common(datetime-format: "[month repr:long] [day padding:none], [year]"),
)

#title-slide()

= Motivation

== The problem

- #todo[problem statement]

= Method

== Our approach: #hl[method name]

#cols[
  - #todo[key idea]
][
  // #fig(image("figures/overview.pdf", height: 70%), caption: [Overview])
]

= Results

== Main results

#todo[table]

#focus-slide[#todo[one-sentence takeaway]]

== Conclusion

#takeaway(title: [Key finding])[#todo[]]

== References

#set text(size: 12pt)
#bibliography("refs.bib", title: none, style: "apa")

#end-slide[
  Herbert Ullrich · #link("mailto:ullriher@fel.cvut.cz")[ullriher\@fel.cvut.cz]
]
