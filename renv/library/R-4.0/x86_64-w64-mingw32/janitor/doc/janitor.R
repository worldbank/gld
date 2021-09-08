## ---- echo = FALSE, message = FALSE-------------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library(janitor)

## ---- message = FALSE, warning = FALSE----------------------------------------
# Create a data.frame with dirty names
test_df <- as.data.frame(matrix(ncol = 6))
names(test_df) <- c("firstName", "ábc@!*", "% successful (2009)",
                    "REPEAT VALUE", "REPEAT VALUE", "")

## -----------------------------------------------------------------------------
test_df %>%
  clean_names()

## -----------------------------------------------------------------------------
make.names(names(test_df))

## -----------------------------------------------------------------------------
df1 <- data.frame(a = 1:2, b = c("big", "small"))
df2 <- data.frame(a = 10:12, b = c("medium", "small", "big"), c = 0, stringsAsFactors = TRUE) # here, column b is a factor
df3 <- df1 %>%
  dplyr::mutate(b = as.character(b))

compare_df_cols(df1, df2, df3)

compare_df_cols(df1, df2, df3, return = "mismatch")
compare_df_cols(df1, df2, df3, return = "mismatch", bind_method = "rbind") # default is dplyr::bind_rows

## -----------------------------------------------------------------------------
compare_df_cols_same(df1, df3)
compare_df_cols_same(df2, df3)

## -----------------------------------------------------------------------------
mtcars %>%
  tabyl(gear, cyl) %>%
  adorn_totals("col") %>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 2) %>%
  adorn_ns() %>%
  adorn_title()

## -----------------------------------------------------------------------------
get_dupes(mtcars, wt, cyl) # or mtcars %>% get_dupes(wt, cyl) if you prefer to pipe

## -----------------------------------------------------------------------------
tibble::as_tibble(iris, .name_repair = janitor::make_clean_names)

## -----------------------------------------------------------------------------
q <- data.frame(v1 = c(1, NA, 3),
                v2 = c(NA, NA, NA),
                v3 = c("a", NA, "b"))
q %>%
  remove_empty(c("rows", "cols"))

## -----------------------------------------------------------------------------
a <- data.frame(good = 1:3, boring = "the same")
a %>% remove_constant()

## -----------------------------------------------------------------------------
nums <- c(2.5, 3.5)
round(nums)
round_half_up(nums)

## -----------------------------------------------------------------------------
excel_numeric_to_date(41103)
excel_numeric_to_date(41103.01) # ignores decimal places, returns Date object
excel_numeric_to_date(41103.01, include_time = TRUE) # returns POSIXlt object
excel_numeric_to_date(41103.01, date_system = "mac pre-2011")

## -----------------------------------------------------------------------------
convert_to_date(c("2020-02-29", "40000.1"))

## -----------------------------------------------------------------------------
dirt <- data.frame(X_1 = c(NA, "ID", 1:3),
           X_2 = c(NA, "Value", 4:6))

row_to_names(dirt, 2)

## -----------------------------------------------------------------------------
f <- factor(c("strongly agree", "agree", "neutral", "neutral", "disagree", "strongly agree"),
            levels = c("strongly agree", "agree", "neutral", "disagree", "strongly disagree"))
top_levels(f)
top_levels(f, n = 1)

