# A Helpers for Marking Classified and a Report template for Use with Typst

SPDX-License Identifier: Unlicense

For `report-v0.5.0`, the minimum Typst version is `v0.12.0`. They can be made to
work with older versions, though.

## Purpose

The purpose of this package is to provide some presets focused on the
classification of a report, such as adding banners, DCA and CUI blocks, as well
as providing a mechanism to colorify the above. It also presets some styling and
enables some optional features that would be useful in a published report.

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

## Old Templates

All of the old templates and plans have been retired. There is a single type
called `report`.

- [x] `work` => `report`
- [x] `simple` => `report`

To enable the features of the old long-form template, such as the title page and
table of contents, pass `title_page: true` to the `report.with()`.
