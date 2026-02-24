#' Orchestrate the entire update process for multiple surveys
#'
#' Reads update specifications from a CSV/Excel file, validates each
#' (country, year, survey) combination upfront, then sequentially executes
#' updates with detailed logging.
#'
#' @param input_file Path to CSV or Excel file with update specifications.
#'   Required columns: country, year, survey, var_name, lines
#'   Each row represents one line of Stata code to place inside the variable
#'   block for that survey.
#' @param base_path  Base path where country folders are stored
#' @param stata_path Path to Stata executable (optional; searches PATH if NULL)
#'
#' @return A tibble with one row per (country, year, survey) combination,
#'   containing columns: country, year, survey, validation_passed,
#'   validation_errors, execution_passed, execution_errors
#'
orchestrate_updates <- function(input_file, base_path, stata_path = NULL) {

  # ------------------------------------------------------------------------#
  # Read and prepare input
  # ------------------------------------------------------------------------#
  
  message("Reading input file: ", input_file)
  updates_raw <- read_updates(input_file)

  required_cols <- c("country", "year", "survey", "var_name", "lines")
  missing_cols  <- setdiff(required_cols, names(updates_raw))
  if (length(missing_cols) > 0) {
    stop("Input file is missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  # ------------------------------------------------------------------------#
  # Group by unique (country, year, survey) combinations
  # ------------------------------------------------------------------------#
  
  survey_groups <- updates_raw |>
    dplyr::distinct(country, year, survey) |>
    dplyr::arrange(country, year, survey)

  # ------------------------------------------------------------------------#
  # Initialise results tracking
  # ------------------------------------------------------------------------#
  
  results <- tibble::tibble(
    country           = character(),
    year              = numeric(),
    survey            = character(),
    validation_passed = logical(),
    validation_errors = character(),
    execution_passed  = logical(),
    execution_errors  = character()
  )

  # ------------------------------------------------------------------------#
  # Process each survey sequentially
  # ------------------------------------------------------------------------#
  
  for (i in seq_len(nrow(survey_groups))) {

    country_i <- survey_groups$country[i]
    year_i    <- survey_groups$year[i]
    survey_i  <- survey_groups$survey[i]

    message("\n", strrep("=", 70))
    message("Processing: ", country_i, " | ", year_i, " | ", survey_i,
            "  (", i, "/", nrow(survey_groups), ")")
    message(strrep("=", 70))

    survey_updates <- updates_raw |>
      dplyr::filter(
        country == country_i,
        year    == year_i,
        survey  == survey_i
      )

    # ----------------------------------------------------------------------#
    # Step 1: Validate
    # ----------------------------------------------------------------------#
    
    validation_result <- validate_survey_combination(
      country    = country_i,
      year       = year_i,
      survey     = survey_i,
      updates_df = survey_updates,
      base_path  = base_path
    )

    results <- results |>
      dplyr::bind_rows(
        tibble::tibble(
          country           = country_i,
          year              = year_i,
          survey            = survey_i,
          validation_passed = validation_result$passed,
          validation_errors = paste(validation_result$errors, collapse = "; "),
          execution_passed  = NA,
          execution_errors  = NA_character_
        )
      )

    if (!validation_result$passed) {
      message("\u2717 VALIDATION FAILED")
      purrr::walk(validation_result$errors, ~message("  - ", .x))
      message("Skipping to next survey...")
      next
    }

    message("\u2713 Validation completed")

    # ----------------------------------------------------------------------#
    # Step 2: Execute
    # ----------------------------------------------------------------------#
    
    execution_result <- execute_survey_updates(
      country    = country_i,
      year       = year_i,
      survey     = survey_i,
      updates_df = survey_updates,
      base_path  = base_path,
      source_gld = validation_result$latest_gld,
      stata_path = stata_path
    )

    results <- results |>
      dplyr::mutate(
        execution_passed = dplyr::if_else(
          country == country_i & year == year_i & survey == survey_i,
          execution_result$passed,
          execution_passed
        ),
        execution_errors = dplyr::if_else(
          country == country_i & year == year_i & survey == survey_i,
          paste(execution_result$errors, collapse = "; "),
          execution_errors
        )
      )

    if (execution_result$passed) {
      message("\u2713 Execution completed successfully")
    } else {
      message("\u2717 EXECUTION FAILED")
      purrr::walk(execution_result$errors, ~message("  - ", .x))
    }
  }

  # ------------------------------------------------------------------------#
  # Final summary
  # ------------------------------------------------------------------------#
  
  message("\n", strrep("=", 70))
  message("FINAL SUMMARY")
  message(strrep("=", 70))

  summary_table <- results |>
    dplyr::mutate(
      status = dplyr::case_when(
        !validation_passed              ~ "VALIDATION FAILED",
        !execution_passed               ~ "EXECUTION FAILED",
        TRUE                            ~ "SUCCESS"
      )
    ) |>
    dplyr::select(country, year, survey, status)

  print(summary_table)

  invisible(results)
}
