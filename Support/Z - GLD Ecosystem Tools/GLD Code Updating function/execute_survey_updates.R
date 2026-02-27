#' Execute updates for a validated (country, year, survey) combination
#'
#' Performs the following steps in sequence:
#' 1. Derive the new _A_GLD folder name (A-version + 1)
#' 2. Create the new folder with:
#'      - Data/Harmonized  (empty - filled in Step 7)
#'      - Programs         (empty, updated .do file will be placed here)
#'      - Doc              (copied from source)
#'      - Work             (copied from source)
#' 3. Copy the source .do file into the new Programs folder, renamed to the
#'      new A-version (e.g. _V06_A_GLD_ALL.do)
#'   3a. Update the local veralt line to the new A-version number
#'   3b. Update the <_Program name_> header line to the new do file name
#' 4. Apply all variable-block updates to the copied .do file
#' 5. Append a new entry to the Version Control block
#' 6. Write the modified .do file back to disk
#' 7. Execute the updated .do file in Stata
#'
#' @param country    Character. Three-letter country code, e.g. "ZAF"
#' @param year       Numeric or character. Survey year, e.g. 2020
#' @param survey     Character. Survey abbreviation, e.g. "QLFS"
#' @param updates_df Tibble. Rows for this survey (columns: country, year,
#'                   survey, var_name, lines)
#' @param base_path  Character. Base path where country folders are stored
#' @param source_gld Full path to the latest (source) _A_GLD folder, as
#'                   returned by validate_survey_combination()
#' @param stata_path Character or NULL. Path to Stata executable
#'
#' @return List with:
#'   - passed: Logical. TRUE if all steps completed successfully
#'   - errors: Character vector of error messages (empty if passed)
execute_survey_updates <- function(country, year, survey,
                                   updates_df, base_path,
                                   source_gld, stata_path = NULL) {

  errors <- character()

  # ------------------------------------------------------------------------#
  # Step 1: Derive new GLD folder path
  # ------------------------------------------------------------------------#
  
  survey_folder  <- build_survey_folder(base_path, country, year, survey)
  new_gld_name   <- next_gld_folder_name(basename(source_gld))
  new_gld_folder <- file.path(survey_folder, new_gld_name)

  message("  Creating: ", new_gld_name)

  # ------------------------------------------------------------------------#
  # Step 2: Create folder structure
  # ------------------------------------------------------------------------#

  # Folders created fresh and empty
  new_dirs_empty <- c(
    file.path(new_gld_folder, "Data", "Harmonized"),
    file.path(new_gld_folder, "Programs")
  )

  for (d in new_dirs_empty) {
    tryCatch(
      {
        dir.create(d, recursive = TRUE, showWarnings = FALSE)
        message("  \u2713 Created: ", d)
      },
      error = function(e) {
        errors <<- c(errors, glue::glue("Failed to create folder '{d}': {e$message}"))
      }
    )
  }

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # Folders copied from source
  dirs_to_copy <- c("Doc", "Work")

  for (dir_name in dirs_to_copy) {
    src <- file.path(source_gld, dir_name)
    dst <- file.path(new_gld_folder, dir_name)

    if (!dir.exists(src)) {
      # Create empty if source doesn't exist rather than failing
      message("  ! Source folder not found, creating empty: ", dst)
      tryCatch(
        dir.create(dst, recursive = TRUE, showWarnings = FALSE),
        error = function(e) {
          errors <<- c(errors, glue::glue(
            "Failed to create folder '{dst}': {e$message}"
          ))
        }
      )
    } else {
      tryCatch(
        {
          # file.copy with recursive = TRUE copies the directory contents
          dir.create(dst, recursive = TRUE, showWarnings = FALSE)
          file.copy(
            from      = list.files(src, full.names = TRUE, recursive = FALSE),
            to        = dst,
            recursive = TRUE,
            overwrite = FALSE
          )
          message("  \u2713 Copied ", dir_name, " from source")
        },
        error = function(e) {
          errors <<- c(errors, glue::glue(
            "Failed to copy '{dir_name}': {e$message}"
          ))
        }
      )
    }
  }

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 3: Copy the .do file into new Programs folder
  # ------------------------------------------------------------------------#

  source_do_file  <- find_do_file(source_gld)[1]   # validated as exactly one

  # The new do file name mirrors the new GLD folder name with _ALL.do appended
  new_do_filename <- paste0(new_gld_name, "_ALL.do")
  new_do_file     <- file.path(new_gld_folder, "Programs", new_do_filename)

  tryCatch(
    {
      file.copy(source_do_file, new_do_file, overwrite = FALSE)
      message("  \u2713 Copied .do file to new Programs folder as: ", new_do_filename)
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Failed to copy .do file: {e$message}"))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # Read file once here; Steps 3a/3b, 4, 5 all operate on do_code in memory
  do_code <- readLines(new_do_file, warn = FALSE)

  # ------------------------------------------------------------------------#
  # Step 3a: Update local veralt to the new A-version number
  # ------------------------------------------------------------------------#

  tryCatch(
    {
      do_code <- update_veralt(do_code, new_gld_name)
      message("  \u2713 Updated local veralt to new A-version")
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Failed to update local veralt: {e$message}"))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 3b: Update <_Program name_> header line to the new do file name
  # ------------------------------------------------------------------------#

  tryCatch(
    {
      do_code <- update_program_name(do_code, new_do_filename)
      message("  \u2713 Updated <_Program name_> to: ", new_do_filename)
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Failed to update Program name header: {e$message}"))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 3c: Update local server path to base_path
  # ------------------------------------------------------------------------#

  tryCatch(
    {
      do_code <- update_server_path(do_code, base_path)
      message("  \u2713 Updated local server to: ", base_path)
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Failed to update local server path: {e$message}"))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 4: Apply variable-block updates
  # ------------------------------------------------------------------------#
  
  updates_pivoted <- pivot_updates_to_wide(updates_df)

  for (var_name in names(updates_pivoted)) {
    new_code_lines <- updates_pivoted[[var_name]]

    tryCatch(
      {
        do_code <- update_code_between_tags(do_code, var_name, new_code_lines)
        message("  \u2713 Updated variable block: ", var_name)
      },
      error = function(e) {
        errors <<- c(errors, glue::glue(
          "Failed to update '{var_name}': {e$message}"
        ))
      }
    )
  }

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 5: Append new Version Control entry
  # ------------------------------------------------------------------------#
  
  tryCatch(
    {
      do_code <- update_version_control(do_code, names(updates_pivoted))
      message("  \u2713 Appended Version Control entry")
    },
    error = function(e) {
      errors <<- c(errors, glue::glue(
        "Failed to update Version Control block: {e$message}"
      ))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 6: Write modified .do file back to disk
  # ------------------------------------------------------------------------#
  
  tryCatch(
    {
      writeLines(do_code, new_do_file)
      message("  \u2713 Wrote updated .do file: ", basename(new_do_file))
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Failed to write .do file: {e$message}"))
    }
  )

  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))

  # ------------------------------------------------------------------------#
  # Step 7: Execute in Stata
  # ------------------------------------------------------------------------#
  
  tryCatch(
    {
      execute_stata_do_file(new_do_file, stata_path)
      message("  \u2713 Stata execution completed")
    },
    error = function(e) {
      errors <<- c(errors, glue::glue("Stata execution failed: {e$message}"))
    }
  )
  
  if (length(errors) > 0) return(list(passed = FALSE, errors = errors))
  
  # Verify that Stata produced the expected harmonised .dta output file.
  expected_dta_name <- paste0(new_gld_name, "_ALL.dta")
  expected_dta_path <- file.path(new_gld_folder, "Data", "Harmonized",
                                 expected_dta_name)
  
  if (!file.exists(expected_dta_path)) {
    errors <- c(errors, glue::glue(
      "Expected output file not found after Stata execution: {expected_dta_path}"
    ))
    return(list(passed = FALSE, errors = errors))
  }
  
  message("  \u2713 Output file verified: ", expected_dta_name)
  
  list(passed = TRUE, errors = character())
}
