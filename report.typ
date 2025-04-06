// A paper or report with classification banners.
// SPDX-License Identifier: Unlicense

//Pick a color based on the classification string
#let colorForClassification(
  classification,
  sci: false,
  disableColor: false,
) = {
  let classcolor = black
  if disableColor == false and classification != none {
    if sci {
      classcolor = rgb("#ffcc00") // Yellow for any SCI (CLASS//SC,I//ETC)
    } else if regex("\bCUI\b|\bCONTROLLED\b") in classification {
       classcolor = rgb("#502b85") // Purple for C(ontrolled) U(Unclass) I(nfo)
    } else if regex("\bU\b|\bUNCLASSIFIED\b") in classification {
       classcolor = rgb("#007a33") // Green for UNCLASSIFIED[//FOUO]
    } else if regex("\bCLASSIFIED\b") in classification {
       classcolor = rgb("#c1a7e2") // Indetermined classified data, ca.1988
    } else if regex("\bC\b|\bCONFIDENTIAL\b") in classification {
       classcolor = rgb("#0033a0") // Blue for CONFIDENTIAL
    } else if regex("\bTS\b|\bTOP SECRET\b") in classification {
       classcolor = rgb("#ff8c00") // Orange for Collateral TS
    } else if regex("\bS\b|\bSECRET\b") in classification {
       classcolor = rgb("#c8102e") // Red for SECRET
    } // else, black because we don't know
  }
  classcolor
}

// Like the above, but return the content with the color applied.
#let classificationWithColor(
  classification,
  sci: false
) = {
  text(
    weight: "bold",
    fill: colorForClassification(classification, sci: sci),
    classification
  )
}

// Wrapper for tables. Adds a banner and formats the headers.
#let classifiedTable(columns: none, caption: none, banner: none, sci: false, header: none, ..fields) = {
  let cols = columns
  if(type(cols) == array) {
    cols = cols.len()
  }
  banner = table.cell(colspan: cols, classificationWithColor(banner, sci: sci))
  if(header != none) {
    header = header.map(
      it => {
        table.cell(fill: rgb("#1f3864"), text(weight: "bold", fill: white, it))
      }
    )
  }
  header = table.header(
    banner,
    ..header,
  )
  figure(caption: caption,
    table(
      columns: columns,
      header,
      ..fields,
      banner
    )
  )
}

// Wrapper for figures to add a banner.
#let classifiedFigure(caption: none, banner: none, sci: false, content) = {
  figure(caption: caption, kind: image,
    table(columns: 1fr, stroke: 1pt,
      table.cell(stroke: (bottom: none), classificationWithColor(banner, sci: sci)),
      table.cell(stroke: (top: none, bottom: none), content),
      table.cell(stroke: (top: none), classificationWithColor(banner)),
    )
  )
}

// Draw CUI and DCA/OCA Blocks
#let drawClassificationBlocks(
  // Fields for DCA Block
  // Required fields:
  //   - by: Person who conducted marking review
  // Optional Fields:
  //   - source: (Derivative classification) Name of SCG used; if multiple, leave blank and
  //     include at the end of the document.
  //      OR
  //   - reason: (Original classification) From 1.4, E.O. 13526
  //   - downgradeto: If the document will be downgraded, what class?
  //   - downgradeon: The date downgrade on which the downgrade can happen
  //   - until: Document will be declassified on this date or condition
  classified,
  // Fields for CUI Block
  // Required Fields:
  //   - controlledby: Array of controllers, ("Division 2", "Office 3")
  //   - categories: Categories ("OPSEC, PRVCY")
  //   - dissemination: Approved dissemination list ("FEDCON")
  //   - poc: POC Name/Contact ("Mr. John Smith, (555) 867-5309")
  cui
) = {
  let dcablock = []
  let cuiblock = []

  if classified != none and regex("SECRET|CONFIDENTIAL|\bCLASSIFIED") in classified.overall {
    dcablock = [
      #set align(left)
      #set par(justify:false)
      *Classified By:* #classified.at("by", default: "MISSING!") \
      #if classified.at("reason", default: none) != none {
        [*Reason:* #classified.at("reason") \ ]
      } else {
        [*Derived From:* #classified.at("source", default: "Multiple Sources") \ ]
      }
      #if classified.at("downgradeto", default: none) != none {
         [*Downgrade To:* #classified.downgradeto \ ]
      }
      #if classified.at("downgradeon", default: none) != none {
         [*Downgrade On:* #classified.downgradeon \ ]
      }
      #if classified.at("until", default: none) != none {
         [*Declassify On:* #classified.until \ ]
      }
    ]
    dcablock = rect(dcablock)
  }

  if cui != none {
    let conby = cui.at("controlledby", default: "MISSING!")
    if type(conby) == array {
      conby = conby.join(strong("\nControlled By: "))
    }
    let cats = cui.at("categories", default: "MISSING!")
    if type(cats) == array {
      cats = cats.join(", ")
    }
    cuiblock = rect[
      #set par(justify:false)
      #set align(left)
      *Controlled By:* #conby \
      *Categories:* #cats \
      *Dissemination:* #cui.at("dissemination", default: "MISSING!") \
      *POC:* #cui.at("poc", default: "MISSING!")
    ]
  }
  place(bottom,  float: true,
    grid( columns: ( 1fr, 1fr ),
      dcablock,
      align(right,cuiblock)
    )
  )
}

// Show the bibliography, if one is attached.
#let showBibliography(
  // Print a bilbiography if given one.
  // This behavior is necessary due to the way typst handles paths.
  // This will likely be updated to use the new path object when added. Issue #971
  biblio,
  title_page: false,
) = {
  if biblio != none {
    set bibliography(title: "References", style: "ieee")
    show bibliography: set text(1em)
    show bibliography: set par(first-line-indent: 0em)
    if title_page {
      show bibliography: set heading(
        numbering: (first, ..other) =>
          if other.pos().len() == 0 {
            return "Appendix " + numbering("A", first) + ":"
          } else {
            numbering("1.", ..other)
          },
        supplement: "Appendix"
      )
      pagebreak()
      biblio
    } else {
      show bibliography: set heading(numbering: "1.")
      biblio
    }
  }
}

// Draw the titles on the page. Only used in report?
#let showTitles(
  // Introduction for the title, i.e. "Trip Report \ for"
  title_intro: none,
  // The actual title: "Operation Drunken Gambler"
  title: none,
  // A subtitle, if needed: "... or, How I Spent My Summer Vacation"
  subtitle: none,
  // A version string if the document may have multiple versions
  version: none,
  // The author of the document
  authors: (),
  // A publication date
  date: none,
) = {
  set par(justify: false)
  set text(hyphenate: false)
  if title_intro != none {
    align(center, text(14pt, title_intro))
  }
  if title != none {
    align(center, text(20pt, title))
  }
  if subtitle != none {
    align(center, text(18pt, subtitle))
  }
  if version != none {
    align(center, text(version))
  }
  if authors != () {
    align(center, authors.join(", "))
  }
  if date != none {
    align(center, date)
  }
  set par(justify: true)
  set text(hyphenate: true)
}

// A full report format.
#let report(
  title_intro: none,
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  classified: none,
  cui: none,
  version: none,
  logo: none,
  border: true,
  title_page: false,
  bib: none,
  paper: "us-letter",
  front: none,
  abstract: none,
  keywords: (),
  body
) = {

  let meta_title = title

  if title_intro != none { meta_title = title_intro + " - " + meta_title }
  if subtitle != none { meta_title = meta_title + " - " + subtitle }

  set document(
    title: meta_title,
    author: authors,
    keywords: keywords,
  )

  set par(justify: true)
  set text(size: 12pt)
  show link: underline
  set heading(numbering: "1.1.1. ")

  show heading: set text(12pt, weight: "bold")

  set enum(indent: 0.25in)
  set list(indent: 0.25in)

  let classification = none

  // Set the classification for the document.
  // If there is no classification, but a CUI block exists, then the document is CUI.
  // There should be no CUI without a CUI block, but if the document is UNCLASSIFIED,
  // then it should be set in `classified.overall`.
  if type(classified) == str {
    classification = classified
    classified = (overall: classified)
  } else if classified != none {
    classification = classified.overall
  } else if cui != none {
    classification = "CUI"
  }

  if type(authors) == str {
    authors = (authors,)
  }

  if classified != none and classified.at("by", default: none) == none and authors != () {
    classified.insert("by", authors.at(0))
  }

  let comment = none
  let sci = false
  if classified != none {
    if ("comment" in classified) {
      comment = [ \ ] + classified.comment
    }
    if ("sci" in classified) {
      sci = classified.sci
    }
  }

  let classcolor = colorForClassification(classification, sci: sci)
  if classified != none and classified.at("color", default: none) != none {
    classcolor = classified.color
  }

  if title_page {
    set page(footer: none, header: none)
    if border == true or type(border) == color {
      let border_color = classcolor
      if type(border) == color {
        border_color = border
      }
      if border_color == color.black {
        border = rect(
            width: 100%-1in,
            height: 100%-1in,
            stroke: 6pt+border_color
        )
      } else {
        border = layout(size => {
          rect(
            width: 100%-1in,
            height: 100%-1in,
            stroke: (size.width * 5%) + border_color
          )
        })
      }
    } else {
      border = none
    }

    set page(paper: paper, background: border)
    set align(horizon)

    showTitles(
      title_intro: title_intro,
      title: title,
      subtitle: subtitle,
      version: version,
      authors: authors,
      date: date)

    // 3in provides a decent logo or a decent size gap
    if logo != none {
      set image(height: 3in)
      align(center, logo)
    } else {
      rect(height: 3in, stroke: none)
    }

    if classification != none {
      align(center, text(fill: classcolor, size: 17pt, strong(classification)))
    }

    if(abstract != none) {
      abstract
    }

    drawClassificationBlocks(classified, cui)
  }

  let header = align(center, text(fill: classcolor, strong(classification)) + comment)

  if title_page {
    // The outline and other "front matter" pages should use Roman numerals.
    let footer = grid(columns: (1fr,auto,1fr),
      [],
      align(center, text(fill: classcolor, strong(classification))),
      align(right, context { counter(page).display("i") })
    )

    page(paper,
      footer: none,
      header: none,
      background: none,
      align(center+horizon,"This page intentionally left blank.")
    )
    
    set page(
      paper: paper,
      header: header,
      footer: footer,
      background: none
    )
    set align(top)
    counter(page).update(1)

    front

    outline(target: heading.where(supplement: [Section]))
    outline(target: heading.where(supplement: [Appendix]), title: none, depth: 1)
    pagebreak(weak: true, to:"odd")

  }

  // Body pages should be numbered with standard Arabic numerals.
  let footer = grid(columns: (1fr,auto,1fr),
    [],
    align(center, text(fill: classcolor, strong(classification))),
    align(right, context { counter(page).display("1") })
  )

  set page(
    paper: paper,
    header: header,
    footer: footer
  )
  counter(page).update(1)

  if not title_page {
    // A 1in logo works well for the top left corner.
    if logo != none {
      set image(height: 1in)
      place(top+left, dy: -0.5in, logo)
    }
    showTitles(
      title_intro: title_intro,
      title: title,
      subtitle: subtitle,
      version: version,
      authors: authors,
      date: date)

    if(abstract != none) {
      abstract
    }

    drawClassificationBlocks(classified, cui)
  }

  body

  set par(justify: false)
  showBibliography(bib, title_page: title_page)
  set par(justify: true)
}

#let appendix(body) = {
  set heading(
    numbering: (first, ..other) =>
      if other.pos().len() == 0 {
        return "Appendix " + numbering("A", first) + ":"
      } else {
        numbering("1.", ..other)
      },
    supplement: "Appendix"
  )
  show heading.where(level: 1): it => {
    pagebreak(weak:true)
    it
  }
  counter(heading).update(0)
  body
}
