csv_output_path <- file.path(getwd(), "gld_programs_comparison")
save_csv <- FALSE

survey_path_1 <- "" # Set to the first survey folder, e.g. "X:\\GLD\\ARM\\ARM_2014_LFS".
survey_path_2 <- "" # Set to the corresponding survey folder on the second server.

gld_checked_io <- function(expr) {
  withCallingHandlers(expr, warning = function(w) {
    stop(conditionMessage(w), call. = FALSE)
  })
}

gld_survey_path <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !nzchar(path) || !dir.exists(path)) {
    stop("Supply an existing survey-level folder: ", paste(path, collapse = ", "),
         call. = FALSE)
  }
  if (file.access(path, 4L) != 0L) {
    stop("Cannot read survey folder: ", path, call. = FALSE)
  }
  normalizePath(path, winslash = "\\", mustWork = TRUE)
}

gld_versions <- function(path, survey) {
  entries <- gld_checked_io(list.files(
    path, full.names = TRUE, all.files = TRUE, no.. = TRUE
  ))
  entries <- entries[dir.exists(entries)]
  names <- basename(entries)
  prefix <- paste0(survey, "_")
  suffix <- substring(names, nchar(prefix) + 1L)
  sort(names[startsWith(names, prefix) &
               grepl("^V[0-9]+_M_V[0-9]+_A_GLD$", suffix)])
}

gld_program_inventory <- function(survey_path, version, version_exists) {
  path <- file.path(survey_path, version, "Programs")
  exists <- version_exists && dir.exists(path)
  if (!exists) {
    return(list(path = path, exists = FALSE, files = character(),
                count = NA_integer_, expectation_met = NA))
  }
  if (file.access(path, 4L) != 0L) {
    stop("Cannot read Programs folder: ", path, call. = FALSE)
  }
  files <- gld_checked_io(list.files(
    path, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ))
  files <- sort(files)
  list(
    path = path, exists = TRUE, files = files, count = length(files),
    expectation_met = length(files) == 1L &&
      tolower(tools::file_ext(files)) == "do"
  )
}

gld_normalized_text <- function(path) {
  size <- gld_checked_io(file.info(path))$size
  if (is.na(size) || file.access(path, 4L) != 0L) {
    stop("Cannot read file: ", path, call. = FALSE)
  }
  bytes <- gld_checked_io(readBin(path, what = "raw", n = size))
  if (length(bytes) != size) {
    stop("Incomplete read (file may have changed): ", path, call. = FALSE)
  }
  # Normalize CRLF and standalone CR without decoding or trimming the text.
  cr <- which(bytes == as.raw(13L))
  next_is_lf <- cr[cr < length(bytes)]
  next_is_lf <- next_is_lf[bytes[next_is_lf + 1L] == as.raw(10L)]
  bytes[cr] <- as.raw(10L)
  if (length(next_is_lf)) {
    bytes <- bytes[-next_is_lf]
  }
  bytes
}

compare_gld_programs <- function(path_1, path_2, save_csv = FALSE,
                                 csv_output_path = file.path(
                                   getwd(), "gld_programs_comparison"
                                 )) {
  if (!is.logical(save_csv) || length(save_csv) != 1L || is.na(save_csv)) {
    stop("save_csv must be TRUE or FALSE.", call. = FALSE)
  }
  path_1 <- gld_survey_path(path_1)
  path_2 <- gld_survey_path(path_2)
  survey <- basename(path_1)
  if (!identical(survey, basename(path_2))) {
    stop("The two survey folders must have the same survey name.",
         call. = FALSE)
  }
  versions_1 <- gld_versions(path_1, survey)
  versions_2 <- gld_versions(path_2, survey)
  versions <- sort(union(versions_1, versions_2))
  if (!length(versions)) {
    stop("Neither survey contains a harmonized folder named ",
         survey, "_V##_M_V##_A_GLD.", call. = FALSE)
  }

  summary_rows <- vector("list", length(versions))
  file_rows <- list()
  for (i in seq_along(versions)) {
    version <- versions[i]
    present_1 <- version %in% versions_1
    present_2 <- version %in% versions_2
    left <- gld_program_inventory(path_1, version, present_1)
    right <- gld_program_inventory(path_2, version, present_2)
    relative_paths <- sort(union(left$files, right$files))
    content_matches <- logical()

    for (relative_path in relative_paths) {
      in_1 <- left$exists && relative_path %in% left$files
      in_2 <- right$exists && relative_path %in% right$files
      same <- NA
      if (in_1 && in_2) {
        same <- identical(
          gld_normalized_text(file.path(left$path, relative_path)),
          gld_normalized_text(file.path(right$path, relative_path))
        )
      }
      content_matches <- c(content_matches, same)
      file_rows[[length(file_rows) + 1L]] <- data.frame(
        harmonized_folder = version, relative_file = relative_path,
        present_1 = in_1, present_2 = in_2, text_same = same,
        status = if (!in_1) "only_in_2" else if (!in_2) "only_in_1" else
          if (same) "same" else "different_text",
        stringsAsFactors = FALSE
      )
    }

    both_programs <- left$exists && right$exists
    count_same <- if (both_programs) left$count == right$count else NA
    names_same <- if (both_programs) identical(left$files, right$files) else NA
    text_same <- if (both_programs && isTRUE(names_same)) {
      all(content_matches)
    } else {
      NA
    }
    identical_programs <- both_programs && isTRUE(count_same) &&
      isTRUE(names_same) && isTRUE(text_same)
    issues <- character()
    if (!present_1) issues <- c(issues, "Harmonized folder missing in path 1")
    if (!present_2) issues <- c(issues, "Harmonized folder missing in path 2")
    if (present_1 && !left$exists) issues <- c(issues, "Programs missing in path 1")
    if (present_2 && !right$exists) issues <- c(issues, "Programs missing in path 2")
    if (left$exists && !left$expectation_met) {
      issues <- c(issues, "Path 1: expected exactly one file, a Stata .do file")
    }
    if (right$exists && !right$expectation_met) {
      issues <- c(issues, "Path 2: expected exactly one file, a Stata .do file")
    }
    if (identical(count_same, FALSE)) issues <- c(issues, "File counts differ")
    if (identical(names_same, FALSE)) issues <- c(issues, "Relative filenames differ")
    if (any(content_matches == FALSE, na.rm = TRUE)) {
      issues <- c(issues, "File text differs")
    }
    summary_rows[[i]] <- data.frame(
      harmonized_folder = version,
      version_present_1 = present_1, version_present_2 = present_2,
      programs_present_1 = left$exists, programs_present_2 = right$exists,
      file_count_1 = left$count, file_count_2 = right$count,
      file_count_same = count_same, filenames_same = names_same,
      text_same = text_same, programs_identical = identical_programs,
      expected_single_do_1 = left$expectation_met,
      expected_single_do_2 = right$expectation_met,
      issues = paste(issues, collapse = "; "), stringsAsFactors = FALSE
    )
  }

  summary <- do.call(rbind, summary_rows)
  files <- if (length(file_rows)) do.call(rbind, file_rows) else data.frame(
    harmonized_folder = character(), relative_file = character(),
    present_1 = logical(), present_2 = logical(), text_same = logical(),
    status = character(), stringsAsFactors = FALSE
  )
  passed <- all(summary$programs_identical) &&
    all(summary$expected_single_do_1 %in% TRUE) &&
    all(summary$expected_single_do_2 %in% TRUE)

  cat("\nSurvey:", survey, "\nPath 1:", path_1, "\nPath 2:", path_2,
      "\nOverall check:", if (passed) "PASS" else "FAIL",
      "\n\nHarmonized-version summary:\n")
  print(summary, row.names = FALSE)
  cat("\nFile-level comparison (NA means not comparable):\n")
  print(files, row.names = FALSE)

  if (save_csv) {
    if (!is.character(csv_output_path) || length(csv_output_path) != 1L ||
        is.na(csv_output_path) || !nzchar(csv_output_path)) {
      stop("csv_output_path must be a nonempty directory path.", call. = FALSE)
    }
    if (!dir.exists(csv_output_path)) {
      created <- gld_checked_io(dir.create(csv_output_path, recursive = TRUE))
      if (!created) stop("Cannot create CSV directory: ", csv_output_path,
                         call. = FALSE)
    }
    summary_file <- file.path(csv_output_path, paste0(survey, "_summary.csv"))
    files_file <- file.path(csv_output_path, paste0(survey, "_files.csv"))
    gld_checked_io(write.csv(summary, summary_file, row.names = FALSE, na = "NA"))
    gld_checked_io(write.csv(files, files_file, row.names = FALSE, na = "NA"))
    cat("\nCSV reports saved to:", csv_output_path, "\n")
  }
  invisible(list(summary = summary, files = files, passed = passed))
}

if (sys.nframe() == 0L) {
  results <- compare_gld_programs(
    survey_path_1, survey_path_2,
    save_csv = save_csv, csv_output_path = csv_output_path
  )
}
