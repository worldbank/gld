# GLD Manual Files - Codified

This folder holds the codified version of the GLD manual. Each chapter is
restated as numbered rules that a harmonizer can cite in a do-file. Under each
rule, the notes give the reason for the rule and the surveys that applied it.

The chapters in `GLD Manual Files` stay unchanged until the team adopts this
version. Compare the two folders to see what changed.

## How to cite a rule

A citation has four levels: title, section, subsection, and paragraph.

`GLD 2.2(c)(3)` means Title 2, section 2, subsection (c), paragraph (3).

A harmonizer writes the citation in the do-file, next to the code that
applies the rule:

```
* age: GLD 2.2(c)(3), no day of interview
```

## The files

| File | Contents |
|---|---|
| `Title 1 - General provisions.md` | The rules that apply to every variable. |
| `Title 2 - Demography.md` | The Demography block, from `Demography.md`. |

## How a section is organized

Every section is about one variable. It has seven parts, always in this
order, with the same letter in every section:

- **(a) Definition.** What the variable measures.
- **(b) Rule.** What the harmonizer shall do.
- **(c) Order of sources.** Which source to use first, and which source to
  use if the first is not available.
- **(d) Exceptions.** The conditions that change the rule.
- **(e) Missing values.** The reference to § 1.1, and any exception to it.
- **(f) Checks.** The tests that show the rule was applied.
- **(g) Notes.** The reason for the rule, the illustrations, the cases, and
  the source in the original manual.

A part with no content says "[Reserved.]". The letter then keeps its meaning,
so `(f)` is always the checks.

Title 1 holds the general rules that apply to every variable, for example the
rule for codes that mean "don't know" or "refused". A section refers to a
general rule. It does not repeat it.

Each title ends with revision notes. They list every change from the original
chapter and the reason for it.

## Status

This is a draft. Demography (Title 2) is the first chapter.

Open questions:

- [#802](https://github.com/worldbank/gld/issues/802): marital status for
  children
- [#803](https://github.com/worldbank/gld/issues/803): the type of
  `relationcs`
