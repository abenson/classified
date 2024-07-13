# A Report template for Use with Typst

SPDX-License Identifier: Unlicense

These files are meant to be used with Typst `v0.7.0`.  They can be made to work
with older versions, though. I believe the only thing I'm using from `v0.7.0`
currently is `float:true`.

## Status

All of the old templates and plans are being retired. There will be a single
type called `report`.

- [x] `work` => `report`
- [x] `simple` => `report`

To enable the features of the old long-form template, such as the title page and
table of contents, pass `title_page: true` to the `report.with()`.

## Why Typst?

I used to have a workflow based around [Pandoc](https://pandoc.org/). It allowed
me to write in Markdown and generate pretty PDFs using Pandoc's [template
system](https://github.com/abenson/custom-pandoc-templates/).

It's major drawback, for me, was an intermediary step that involved LaTeX.
TeXLive is huge, cumbersome, and on some of my smaller systems, such as my
Chromebook or ancient PowerBook, disk space is a limited commodity.

I began looking for a replacement, settling on reStructuredText and
[Rinoh](https://www.mos6581.org/rinohtype/) for a very short period of time,
until I found Typst.

[Typst](https://typst.app) is a typesetting framework similar to TeX and LaTeX,
but much smaller and with a newly designed language. Also, it borrows a lot of
inline formatting from other frameworks, such as `_italics_` and `*bold*`, which
make it easy to work with quickly.
