#' Validate a single (country, year, survey) combination
#'
#' Performs all upfront checks before any file operations:
#' 1. Survey-level folder exists
#' 2. At least one _A_GLD folder exists within it
#' 3. The latest _A_GLD folder contains a Programs subfolder with exactly
#'    one .do file
#' 4. Every variable named in the update has a matching marker block in
#'    the .do file
#' 5. Each update differs from the current code (no redundant updates)
#'
#' @param country    Character. Three-letter country code, e.g. "ZAF"
#' @param year       Numeric or character. Survey year, e.g. 2020
#' @param survey     Character. Survey abbreviation, e.g. "QLFS"
#' @param updates_df Tibble. Rows for this survey (columns: country, year,
#'                   survey, var_name, lines)
#' @param base_path  Character. Base path where country folders are stored
#'
#' @return List with:
#'   - passed: Logical. TRUE if all validations pass
#'   - errors: Character vector of error messages (empty if passed)
#'   - latest_gld: Full path to the latest _A_GLD folder (NULL if failed
#'     early)
validate_survey_combination <- function(country, year, survey,
                                        updates_df, base_path) {

  errors <- character()

  # ------------------------------------------------------------------------#
  # Check 1: Survey-level folder exists
  # ------------------------------------------------------------------------#
  
  survey_folder <- build_survey_folder(base_path, country, year, survey)

  if (!dir.exists(survey_folder)) {
    return(list(
      passed     = FALSE,
      errors     = glue::glue("Survey folder does not exist: {survey_folder}"),
      latest_gld = NULL
    ))
  }

  # ------------------------------------------------------------------------#
  # Check 2: At least one _A_GLD folder exists
  # ------------------------------------------------------------------------#
  
  gld_folders <- find_gld_folders(survey_folder)

  if (length(gld_folders) == 0) {
    return(list(
      passed     = FALSE,
      errors     = glue::glue(
        "No _A_GLD folders found in: {survey_folder}"
      ),
      latest_gld = NULL
    ))
  }

  source_gld <- latest_gld_folder(gld_folders)

  # ------------------------------------------------------------------------#
  # Check 3: Programs folder contains exactly one .do file
  # ------------------------------------------------------------------------#
  
  programs_dir <- file.path(source_gld, "Programs")

  if (!dir.exists(programs_dir)) {
    return(list(
      passed     = FALSE,
      errors     = glue::glue(
        "Programs folder does not exist in: {source_gld}"
      ),
      latest_gld = source_gld
    ))
  }

  do_files <- find_do_file(source_gld)

  if (length(do_files) == 0) {
    errors <- c(errors, glue::glue(
      "No .do file found in Programs folder: {programs_dir}"
    ))
  } else if (length(do_files) > 1) {
    errors <- c(errors, glue::glue(
      "Multiple .do files found in Programs folder ({programs_dir}): ",
      "{paste(basename(do_files), collapse = ', ')}"
    ))
  }

  if (length(errors) > 0) {
    return(list(passed = FALSE, errors = errors, latest_gld = source_gld))
  }

  do_file_path <- do_files[1]
  do_code      <- readLines(do_file_path, warn = FALSE)

  # ------------------------------------------------------------------------#
  # Check 4 & 5: Each variable has a marker block, and the proposed update
  # differs from the current code
  # ------------------------------------------------------------------------#
  
  updates_pivoted <- pivot_updates_to_wide(updates_df)

  for (var_name in names(updates_pivoted)) {

    current_code <- extract_current_code_for_variable(do_code, var_name)

    if (length(current_code) == 1 && is.na(current_code)) {
      errors <- c(errors, glue::glue(
        "Variable '{var_name}': markers *<_{var_name}_> / *</_{var_name}_> ",
        "not found in {basename(do_file_path)}"
      ))
    } else if (identical(updates_pivoted[[var_name]], current_code)) {
      errors <- c(errors, glue::glue(
        "Variable '{var_name}': proposed update is identical to current ",
        "code (redundant update)"
      ))
    }
  }

  # ------------------------------------------------------------------------#
  # Check: Version Control block exists
  # ------------------------------------------------------------------------#
  
  has_vc_start <- any(grepl("<_Version Control_>",  do_code, fixed = TRUE))
  has_vc_end   <- any(grepl("</_Version Control_>", do_code, fixed = TRUE))

  if (!has_vc_start || !has_vc_end) {
    errors <- c(errors, glue::glue(
      "Version Control block not found in {basename(do_file_path)}. ",
      "Expected markers: <_Version Control_> and </_Version Control_>"
    ))
  }

  if (length(errors) > 0) {
    return(list(passed = FALSE, errors = errors, latest_gld = source_gld))
  }

  list(passed = TRUE, errors = character(), latest_gld = source_gld)
}
