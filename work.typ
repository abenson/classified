// A paper or report with classification banners.
// SPDX-License Identifier: Unlicense

//Pick a color based on the classification string
#let colorForClassification(
  classification,
  disableColor: false
) = {
  let classcolor = black
  if disableColor == false and classification != none {
    if regex("UNCLASSIFIED") in classification {
       classcolor = rgb("#007a33") // Green for UNCLASSIFIED[//FOUO]
    } else if regex("CUI|CONTROLLED") in classification {
       classcolor = rgb("#502b85") // Purple for C(ontrolled) U(Unclass) I(nfo)
    } else if regex("CONFIDENTIAL") in classification {
       classcolor = rgb("#0033a0") // Blue for CONFIDENTIAL
    } else if regex("TOP SECRET") in classification {
       classcolor = rgb("#ff8c00") // Orange for Collateral TS
    } else if regex("SECRET") in classification {
       classcolor = rgb("#c8102e") // Red for SECRET
    } else if regex("//.*//") in classification {
       classcolor = rgb("#fce83a") // Yellow for any SCI (CLASS//SC,I//ETC)
    } // else, black because we don't know
  }
  classcolor
}

// Draw CUI and DCA Blocks, same for both simple and report (sorry, OCAs)
#let drawClassificationBlocks(
  // Fields for DCA Block
  // Required fields:
  //   - by: Person who conducted marking review
  // Optional Fields:
  //   - sources: Name of SCG used; if multiple, leave blank and
  //     include at the end of the document.
  //   - downgradeto: If the document will be downgraded, what class?
  //   - downgradeon: The date downgrade on which the downgrade can happen
  //   - until: Document will be declassified on this date, i.e. $date+25y, $date+75y
  classified,
  // Fields for CIU Block
  // Required Fields:
  //   - controlledby: Array of controllers, ("Division 2", "Office 3")
  //   - categories: Categories ("OPSEC, PRVCY")
  //   - dissemination: Approved dissemination list ("FEDCON")
  //   - poc: POC Name/Contact ("Mr. John Smith, (555) 867-5309")
  cui
) = {
  let dcablock = []
  let cuiblock = []

  if classified != none and regex("UNCLASSIFIED|CUI") not in classified.overall {
    dcablock = [
       *Classified By:* #classified.at("by", default: "MISSING!") \
       *Derived From:* #classified.at("source", default: "Multiple Sources") \
    ]
    if classified.at("downgradeto", default: []) != [] {
       dcablock += [*Downgrade To:* #classified.downgradeto \ ]
    }
    if classified.at("downgradeon", default: []) != [] {
       dcablock += [*Downgrade On:* #classified.downgradeon \ ]
  }

  if classified.at("until", default: []) != []{
       dcablock += [*Declassify On:* #classified.until\ ]
  }
    dcablock = rect(dcablock)
  }

  if cui != none {
    cuiblock = rect[
      *Controlled By:* #cui.at("controlledby", default: ("MISSING!",)).join(strong("\nControlled By: "))\
      *Categories:* #cui.at("categories", default: "MISSING!") \
      *Dissemination:* #cui.at("dissemination", default: "MISSING!") \
      *POC:* #cui.at("poc", default: "MISSING!")
    ]
  }
  place(bottom,  float: true,
    grid( columns: ( 1fr, 1fr ),
      dcablock,
      cuiblock
    )
  )
}

// Show the bibliography, if one is attached.

#let showBibliography(
  // Path to the bibliography file, i.e. "reference.yaml"
  biblioFile
) = {
  if biblioFile != none {
    show bibliography: set text(1em)
    show bibliography: set par(first-line-indent: 0em)
    bibliography(biblioFile, title: [References], style: "ieee")
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
  author: none,
  // A publication date
  date: none
) = {
  if title_intro != none {
    align(center, text(14pt, title_intro))
  }
  if title != none {
    align(center, text(25pt, title))
  }
  if subtitle != none {
    align(center, text(17pt, subtitle))
  }
  if version != none {
    align(center, text(version))
  }
  if author != none {
    align(center, author)
  }
  if date != none {
    align(center, date)
  }
}

// Simple title block at the top, set some headers, footers, and draw a
// bibliography, that's it.
#let simple(
  title_intro: none,
  title: none,
  subtitle: none,
  version: none,
  author: none,
  date: none,
  classified: none,
  cui: none,
  bib: none,
  paper: "us-letter",
  body
) = {
  set par(justify: true)
  set text(size: 12pt)
  show link: underline

  let classification = ""

  if classified != () {
    classification = classified.overall
  } else if cui != () {
    classification = "CUI"
  }

  let classcolor = classifiedcolor(classification)
  let header = align(center, text(fill: classcolor, strong(classification)))
  let footer = [
    #h(1fr) #text(fill: classcolor, strong(classification))
    #h(1fr) #counter(page).display()
  ]

  set page(
    paper: paper,
    header: header,
    footer: footer
  )

  showTitles(
    title_intro: title_intro,
    title: title,
    subtitle: subtitle,
    version: version,
    author: author,
    date: date)

  drawClassificationBlocks(classified, cui)

  body
  
  showBibliography(bib)
}

// A full report format.
#let report(
  title_intro: none,
  title: none,
  subtitle: none,
  author: none,
  date: none,
  classified: none,
  cui: none,
  version: none,
  logo: none,
  bib: none,
  paper: "us-letter",
  body
) = {
  set par(justify: true)
  set text(size: 12pt)
  show link: underline
  set heading(numbering: "1.1.1. ")

  let classification = none

  // Set the classification for the document.
  // If there is no classification, but a CUI block exists, then the document is CUI.
  // There should be no CUI without a CUI block, but if the document is UNCLASSIFIED,
  // then it should be set in `classified.overall`.
  if classified != none {
    classification = classified.overall
  } else if cui != none {
    classification = "CUI"
  }

  let classcolor = colorForClassification(classification)

  set page(paper: paper)
  set align(horizon)

  showTitles(
    title_intro: title_intro,
    title: title,
    subtitle: subtitle,
    version: version,
    author: author,
    date: date)

  // 3in provides a decent logo or a decent size gap
  if logo != none {
    align(center, image(height: 3in, logo))
  } else {
    rect(height: 3in, stroke: none)
  }

  if classification != none {
    align(center)[The Overall Classification of this Document is]
    align(center, text(fill: classcolor, size: 17pt, strong(classification)))
  }

  drawClassificationBlocks(classified, cui)

  // The outline and other "front matter" pages should use Roman numerals.
  let header = align(center, text(fill: classcolor, strong(classification)))
  let footer = [
    #h(1fr) #text(fill: classcolor, strong(classification))
    #h(1fr) #counter(page).display("i")
  ]

  set page(
    paper: paper,
    header: header,
    footer: footer
  )
  set align(top)
  counter(page).update(1)

  outline()

  // Body pages should be numbered with standard Arabic numerals.
  footer = [
    #h(1fr) #text(fill: classcolor, strong(classification))
    #h(1fr) #counter(page).display("1")
  ]

  set page(
    paper: paper,
    header: header,
    footer: footer
  )
  counter(page).update(1)
  
  body
  
  showBibliography(bib)
}
