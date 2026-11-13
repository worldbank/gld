source("compare_gld_programs.R")

local({
  root <- tempfile("gld-programs-tests-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  survey <- "ARM_2014_LFS"
  left <- file.path(root, "left", survey)
  right <- file.path(root, "right", survey)
  output <- file.path(root, "reports")
  v1 <- paste0(survey, "_V01_M_V01_A_GLD")
  v2 <- paste0(survey, "_V01_M_V02_A_GLD")
  program_path <- function(side, version = v1) {
    file.path(side, version, "Programs")
  }
  dir.create(program_path(left), recursive = TRUE)
  dir.create(program_path(right), recursive = TRUE)
  put <- function(path, text) writeBin(charToRaw(text), path)
  run <- function(save = FALSE) {
    capture.output(result <- compare_gld_programs(
      left, right, save_csv = save, csv_output_path = output
    ))
    result
  }
  expect_error <- function(expr, pattern) {
    error <- tryCatch({ force(expr); NULL }, error = identity)
    stopifnot(inherits(error, "error"),
              grepl(pattern, conditionMessage(error), fixed = TRUE))
  }
  a <- file.path(program_path(left), "main.do")
  b <- file.path(program_path(right), "main.do")
  put(a, "clear\r\n* comment\r\n")
  put(b, "clear\n* comment\n")
  result <- run()
  stopifnot(result$passed, result$summary$file_count_same,
            result$summary$filenames_same, result$summary$text_same,
            result$files$status == "same", !dir.exists(output))

  put(a, "clear\r* comment\r")
  stopifnot(run()$passed)
  put(b, "clear\n*  comment\n")
  result <- run()
  stopifnot(!result$passed, !result$summary$text_same,
            result$files$status == "different_text")
  put(b, "clear\n* comment")
  stopifnot(!run()$summary$text_same)
  put(b, "clear\n* comment\n")

  dir.create(file.path(program_path(left), "helpers"))
  dir.create(file.path(program_path(right), "helpers"))
  put(file.path(program_path(left), "helpers", ".extra.txt"), "extra\n")
  put(file.path(program_path(right), "helpers", ".extra.txt"), "extra\n")
  result <- run()
  stopifnot(!result$passed, result$summary$programs_identical,
            result$summary$file_count_1 == 2L,
            !result$summary$expected_single_do_1,
            any(result$files$relative_file == "helpers/.extra.txt"))
  unlink(file.path(program_path(right), "helpers", ".extra.txt"))
  result <- run()
  stopifnot(!result$summary$file_count_same,
            !result$summary$filenames_same, is.na(result$summary$text_same),
            result$files$status[result$files$relative_file ==
                                  "helpers/.extra.txt"] == "only_in_1")
  unlink(file.path(program_path(left), "helpers", ".extra.txt"))

  stopifnot(file.rename(b, file.path(program_path(right), "renamed.do")))
  result <- run()
  stopifnot(result$summary$file_count_same, !result$summary$filenames_same,
            all(is.na(result$files$text_same)))
  stopifnot(file.rename(file.path(program_path(right), "renamed.do"), b))

  dir.create(program_path(left, v2), recursive = TRUE)
  put(file.path(program_path(left, v2), "main.do"), "clear\n")
  result <- run()
  missing <- result$summary[result$summary$harmonized_folder == v2, ]
  stopifnot(!missing$version_present_2, is.na(missing$file_count_2),
            !missing$programs_identical)
  dir.create(file.path(right, v2), recursive = TRUE)
  result <- run()
  missing <- result$summary[result$summary$harmonized_folder == v2, ]
  stopifnot(missing$version_present_2, !missing$programs_present_2,
            grepl("Programs missing in path 2", missing$issues, fixed = TRUE))
  dir.create(program_path(right, v2))
  unlink(file.path(program_path(left, v2), "main.do"))
  result <- run()
  empty <- result$summary[result$summary$harmonized_folder == v2, ]
  stopifnot(empty$programs_identical, empty$file_count_1 == 0L,
            !empty$expected_single_do_1, !result$passed)
  unlink(file.path(left, v2), recursive = TRUE)
  unlink(file.path(right, v2), recursive = TRUE)

  stopifnot(file.rename(a, file.path(program_path(left), "main.txt")))
  stopifnot(file.rename(b, file.path(program_path(right), "main.txt")))
  result <- run()
  stopifnot(result$summary$programs_identical, !result$passed)
  stopifnot(file.rename(file.path(program_path(left), "main.txt"), a))
  stopifnot(file.rename(file.path(program_path(right), "main.txt"), b))

  # Master-folder Programs must not enter the comparison.
  dir.create(file.path(left, paste0(survey, "_V01_M"), "Programs"),
             recursive = TRUE)
  result <- run(TRUE)
  stopifnot(result$passed,
            identical(read.csv(file.path(output, paste0(survey, "_summary.csv")),
                               stringsAsFactors = FALSE), result$summary),
            identical(read.csv(file.path(output, paste0(survey, "_files.csv")),
                               stringsAsFactors = FALSE), result$files))
  expect_error(compare_gld_programs("", right), "existing survey-level folder")
  expect_error(compare_gld_programs(left, right, save_csv = NA),
               "save_csv must be TRUE or FALSE")
  expect_error(compare_gld_programs(left, dirname(right)),
               "same survey name")
  unlink(file.path(left, v1), recursive = TRUE)
  unlink(file.path(right, v1), recursive = TRUE)
  expect_error(compare_gld_programs(left, right), "Neither survey contains")
  cat("All GLD Programs comparison tests passed.\n")
})
