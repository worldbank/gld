## ----chunk_options, include = FALSE-------------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")

## ----clean_starwars, warning = FALSE, message = FALSE-------------------------
library(dplyr)
humans <- starwars %>%
  filter(species == "Human")

## ----one_way------------------------------------------------------------------
library(janitor)

t1 <- humans %>%
  tabyl(eye_color)

t1

## ----one_way_vector-----------------------------------------------------------
x <- c("big", "big", "small", "small", "small", NA)
tabyl(x)

## ----one_way_adorns-----------------------------------------------------------
t1 %>%
  adorn_totals("row") %>%
  adorn_pct_formatting()

## ----two_way------------------------------------------------------------------
t2 <- humans %>%
  tabyl(gender, eye_color)

t2

## ----two_way_adorns-----------------------------------------------------------

t2 %>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 2) %>%
  adorn_ns()

## ----three_Way----------------------------------------------------------------
t3 <- humans %>%
  tabyl(eye_color, skin_color, gender)

# the result is a tabyl of eye color x skin color, split into a list by gender
t3 

## ----three_way_adorns, warning = FALSE, message = FALSE-----------------------
library(purrr)
humans %>%
  tabyl(eye_color, skin_color, gender, show_missing_levels = FALSE) %>%
  adorn_totals("row") %>%
  adorn_percentages("all") %>%
  adorn_pct_formatting(digits = 1) %>%
  adorn_ns %>%
  adorn_title


## -----------------------------------------------------------------------------
humans %>%
  tabyl(gender, eye_color) %>%
  adorn_totals(c("row", "col")) %>%
  adorn_percentages("row") %>% 
  adorn_pct_formatting(rounding = "half up", digits = 0) %>%
  adorn_ns() %>%
  adorn_title("combined") %>%
  knitr::kable()


## ----first_non_tabyl----------------------------------------------------------
percent_above_165_cm <- humans %>%
  group_by(gender) %>%
  summarise(pct_above_165_cm = mean(height > 165, na.rm = TRUE), .groups = "drop")

percent_above_165_cm %>%
  adorn_pct_formatting()

## ----tidyselect, warning = FALSE, message = FALSE-----------------------------
mtcars %>%
  count(cyl, gear) %>%
  rename(proportion = n) %>%
  adorn_percentages("col", na.rm = TRUE, proportion) %>%
  adorn_pct_formatting(,,,proportion) # the commas say to use the default values of the other arguments

## ----dont_total, warning = FALSE, message = FALSE-----------------------------
cases <- data.frame(
  region = c("East", "West"),
  year = 2015,
  recovered = c(125, 87),
  died = c(13, 12)
)

cases %>%
    adorn_totals(c("col", "row"), fill = "-", na.rm = TRUE, name = "Total Cases", recovered:died)

## ----more_non_tabyls, warning = FALSE, message = FALSE------------------------
library(tidyr) # for spread()
mpg_by_cyl_and_am <- mtcars %>%
  group_by(cyl, am) %>%
  summarise(mpg = mean(mpg), .groups = "drop") %>%
  spread(am, mpg)

mpg_by_cyl_and_am

## ----add_the_Ns---------------------------------------------------------------
mpg_by_cyl_and_am %>%
  adorn_rounding() %>%
  adorn_ns(
    ns = mtcars %>% # calculate the Ns on the fly by calling tabyl on the original data
      tabyl(cyl, am)
  ) %>%
  adorn_title("combined", row_name = "Cylinders", col_name = "Is Automatic")

## ----formatted_Ns_thousands_prep----------------------------------------------
set.seed(1)
raw_data <- data.frame(sex = rep(c("m", "f"), 3000),
                age = round(runif(3000, 1, 102), 0))
raw_data$agegroup = cut(raw_data$age, quantile(raw_data$age, c(0, 1/3, 2/3, 1)))

comparison <- raw_data %>%
  tabyl(agegroup, sex, show_missing_levels = F) %>%
  adorn_totals(c("row", "col")) %>%
  adorn_percentages("col") %>%
  adorn_pct_formatting(digits = 1)

comparison

## ----adorn_ns_unformatted-----------------------------------------------------
comparison %>%
  adorn_ns()

## ----formatted_Ns_thousands---------------------------------------------------
formatted_ns <- attr(comparison, "core") %>% # extract the tabyl's underlying Ns
  adorn_totals(c("row", "col")) %>% # to match the data.frame we're appending to
  dplyr::mutate_if(is.numeric, format, big.mark = ",")

comparison %>%
  adorn_ns(position = "rear", ns = formatted_ns)

