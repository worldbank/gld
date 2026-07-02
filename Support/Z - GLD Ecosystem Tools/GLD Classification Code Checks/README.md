# GLD Classification Code Checks

## What is the issue?

GLD harmonization often needs to identify whether raw industry and occupation codes align with an ISIC or ISCO revision before assigning `industrycat_isic` or `occup_isco`.

These Stata helper commands compare the unique codes in the loaded data with the GLD helper lists used in the single-survey quality checks.

## How is it addressed?

The folder includes two commands:

- `gld_isic_check`: checks industry codes against available ISIC helper-list versions.
- `gld_isco_check`: checks occupation codes against available ISCO helper-list versions.

Each command reports how many unique codes match each reference version and the share of unique codes matched. With the `show` option, the command lists codes in the data that do not match a given reference version.

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
