# Compare GLD harmonization Programs folders

This dependency-free R script compares two copies of the same survey-level
folder, for example `ARM_2014_LFS`, following the structure in
[GLD content, storage, and access](../../A%20-%20Guides%20and%20Documentation/GLD%20Manual%20Files/GLD%20content,%20storage,%20and%20access.md).
It does not inspect master-data Programs folders, microdata, or documentation.

## Run

At the start of [compare_gld_programs.R](compare_gld_programs.R), configure:

- `csv_output_path`: the directory for CSV reports.
- `save_csv`: whether to save reports; defaults to `FALSE`.
- `survey_path_1` and `survey_path_2`: the two survey folder paths.
  In R strings, use doubled backslashes, such as `"X:\\GLD\\ARM\\ARM_2014_LFS"`.

Run the entire script with Rscript. Alternatively, source it and call the
function explicitly (sourcing only defines settings and functions):

```r
source("compare_gld_programs.R")
results <- compare_gld_programs(
  path_1 = "X:\\GLD\\ARM\\ARM_2014_LFS",
  path_2 = "Y:\\GLD\\ARM\\ARM_2014_LFS",
  save_csv = save_csv,
  csv_output_path = csv_output_path
)
```

## Checks and results

- Discover all immediate harmonized folders matching
  `<survey>_V<number>_M_V<number>_A_GLD`; pair by exact folder name.
  Versions present on only one side are reported, not ignored.
- Recursively compare all files in each `Programs` folder, including hidden
  files. Filenames are matched case-sensitively by relative path, so moved or
  renamed files are reported as missing on one side.
- Compare file counts, relative filenames, and contents. Only CRLF and CR line
  endings are normalized to LF. Spaces, comments, blank lines, byte-order
  marks, encoding differences, and the presence of a final newline still count
  as differences. No encoding conversion is attempted.
- Flag any existing `Programs` folder unless it contains exactly one file and
  that file has a `.do` extension (case-insensitive).
- Print version-level and file-level data frames and an overall PASS/FAIL.
  The returned list exposes `summary`, `files`, and `passed`.
- Missing folders produce explicit issues; their counts and comparisons are
  `NA`, not zero or successful matches. File-level `text_same` is `NA` for files
  missing on one side. Summary `text_same` is `NA` unless both Programs folders
  exist and their filename sets match.
- Two empty Programs folders have identical contents, but fail the single-do
  expectation and therefore fail the overall check.
- Invalid paths, different survey names, no discovered harmonized versions,
  and I/O errors stop execution with an error instead of reporting success.

With saving enabled, the script creates the output directory if needed and
writes `<survey>_summary.csv` and `<survey>_files.csv`. Subsequent runs overwrite
these two reports. With saving disabled, it creates no output directory or CSVs.
Run against stable folders: concurrent edits during comparison are unsupported.

## Tests

Run `Rscript test_compare_gld_programs.R` from this directory. Tests use temporary
survey folders and base R only.
