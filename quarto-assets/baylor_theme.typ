// Define Baylor Colors
#let baylor-green = rgb("#154734")
#let baylor-gold = rgb("#FFB81C")

// --- Quarto Metadata Block Fixes ---
// Target the centered block that Quarto uses for the Title, Author, and Date
#show align.where(alignment: center): it => {
  // Target the title specifically by catching the bold text
  show text.where(weight: "bold"): set text(size: 2.8em, fill: baylor-green)
  
  // Enlarge the Author and Date text
  set text(size: 1.4em)
  
  // Aggressively compress the vertical spacing
  set block(above: 0.1em, below: 0.1em, spacing: 0.1em)
  it
}

// Compress the grid that Quarto uses to lay out the Author and Date
#show grid: set block(above: 0.1em, below: 0.1em, spacing: 0.1em)

// --- Heading Hierarchy ---
// Explicitly scaled down so the Title is definitively the largest element
// Level 1
#show heading.where(level: 1): it => block(above: 1.2em, below: 0.6em)[
  #set text(weight: "bold", size: 1.1em, fill: baylor-green)
  #it
]

// Level 2
#show heading.where(level: 2): it => block(above: 1em, below: 0.5em)[
  #set text(weight: "bold", size: 1.05em, fill: baylor-green)
  #it
]

// Level 3
#show heading.where(level: 3): it => block(above: 1em, below: 0.5em)[
  #set text(weight: "bold", size: 1.0em, fill: baylor-green)
  #it
]

// --- First Page Logo Placement ---
#set page(footer: context {
  if counter(page).get().first() == 1 {
    align(center)[#image("quarto-assets/baylor.png", width: 25%)]
  }
})

// --- Hyperlink Styling ---
// Make links obvious with Baylor Green and an underline
#show link: set text(fill: baylor-green)
#show link: underline

// --- Custom Definition Styling ---
// Applies a 30% lighter Baylor Green and italics
#let defn(body) = {
  text(fill: baylor-green.lighten(30%), style: "italic", body)
}