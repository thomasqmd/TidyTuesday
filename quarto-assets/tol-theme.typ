// Define Tol Colors
#let tol-indigo = rgb("#332288")
#let tol-green  = rgb("#117733")
#let tol-teal   = rgb("#44AA99")
#let tol-cyan   = rgb("#88CCEE")
#let tol-sand   = rgb("#DDCC77")
#let tol-rose   = rgb("#CC6677")
#let tol-purple = rgb("#AA4499")
#let tol-wine   = rgb("#882255")
#let tol-black  = rgb("#000000")

// --- Quarto Metadata Block Fixes ---
#show align.where(alignment: center): it => {
  show text.where(weight: "bold"): set text(size: 2.8em, fill: tol-green)
  set text(size: 1.4em)
  set block(above: 0.1em, below: 0.1em, spacing: 0.1em)
  it
}
#show grid: set block(above: 0.1em, below: 0.1em, spacing: 0.1em)

// --- Heading Hierarchy ---
#show heading.where(level: 1): it => block(above: 1.2em, below: 0.6em)[
  #set text(weight: "bold", size: 1.1em, fill: tol-green)
  #it
]

#show heading.where(level: 2): it => block(above: 1em, below: 0.5em)[
  #set text(weight: "bold", size: 1.05em, fill: tol-green)
  #it
]

#show heading.where(level: 3): it => block(above: 1em, below: 0.5em)[
  #set text(weight: "bold", size: 1.0em, fill: tol-green)
  #it
]

// --- First Page Logo Placement ---
#set page(footer: context {
  if counter(page).get().first() == 1 {
    align(center)[#image("quarto-assets/baylor.png", width: 25%)]
  }
})

// --- Hyperlink Styling ---
#show link: set text(fill: tol-green)
#show link: underline



// --- Custom Definition Styling ---
#let defn(body) = [
  #text(fill: tol-green.lighten(10%), style: "italic", body)
]

#show terms.item: it => {
  strong(defn(it.term))
  [: ]
  it.description
}
