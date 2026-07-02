# GLD Classification Code Checks

## What is the issue?

GLD harmonization often needs to identify which ISIC or ISCO revision a raw industry or occupation variable most likely follows before assigning `industrycat_isic` or `occup_isco`.

The main difficulty is that the raw data may contain only numeric codes, while the questionnaire or codebook may not clearly state the classification revision. In those cases, a harmonizer needs a quick way to compare the observed code list against the available GLD reference lists.

## How is it addressed?

This folder includes two Stata commands:

- `gld_isic_check`: compares observed industry codes against available ISIC helper-list versions.
- `gld_isco_check`: compares observed occupation codes against available ISCO helper-list versions.

Each command collapses the loaded data to the unique non-missing codes in the selected variable, then compares those unique codes with every available reference version. The command reports the number and share of unique observed codes that match each version. With the `show` option, it lists the observed codes that do not match each version.

## How is this different from the ISIC ISCO universe check?

This tool is related to, but different from, the existing [`ISIC ISCO universe check`](../ISIC%20ISCO%20universe%20check/README.md).

Use the existing `int_classif_universe` command when:

- the data are already harmonized,
- the dataset already has `isic_version` or `isco_version`,
- you want to check one known classification universe, and
- you want a dataset listing out-of-universe codes with the number of records affected.

Use `gld_isic_check` or `gld_isco_check` when:

- you are still deciding which ISIC or ISCO revision the source codes resemble,
- the source is a raw or candidate harmonization variable,
- you want to compare the same observed code list against all available reference versions, and
- you want a quick unique-code match diagnostic before finalizing the harmonization rule.

In short, `int_classif_universe` is a post-harmonization validation tool for a known version. These commands are pre-harmonization or review diagnostics for identifying which version best fits the observed codes.

These commands also count unique observed codes, not records. A code that appears once and a code that appears many times have the same weight in the match percentage. If the concern is the number of affected observations after a version has been selected, use `int_classif_universe`.

## How is this different from the Global collection R check?

The `Global collection/isic_isco_checks.R` script checks the share of non-missing `industrycat_isic` and `occup_isco` values by year in a prepared data object. It is a coverage check. It does not compare observed codes to ISIC or ISCO reference lists.

The commands in this folder check whether the observed code values themselves match the possible values in ISIC or ISCO reference versions.

## How to install the functions?

The functions can be installed directly from the internet by typing the following into the Stata console:

```stata
net install gld_classification_code_checks, replace from("https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/GLD%20Classification%20Code%20Checks")
```

Keep the `replace` option so Stata can overwrite the code if the functions are updated.

## How to run the code?

With a dataset loaded, run:

```stata
gld_isic_check
gld_isco_check
```

By default, `gld_isic_check` uses `industrycat_isic` and `gld_isco_check` uses `occup_isco`. To use another variable:

```stata
gld_isic_check, industry(raw_industry_variable)
gld_isco_check, occupation(raw_occupation_variable)
```

To list unmatched codes for each version:

```stata
gld_isic_check, industry(raw_industry_variable) show
gld_isco_check, occupation(raw_occupation_variable) show
```

## How to interpret the output?

The output is a screening diagnostic. A 100 percent match with a version is strong evidence that all observed codes are valid in that reference list. A lower match percentage means some observed codes are not in that version.

This does not prove that the survey officially used the version with the highest match. The final decision should still consider the questionnaire, codebook, labels, official survey documentation, and any country-specific classification notes.
