## ----initial, echo = FALSE, cache = FALSE, results = 'hide'-------------------
knitr::opts_chunk$set(
  warning = FALSE, message = FALSE, echo = TRUE,
  fig.width = 7, fig.height = 6, fig.align = 'centre',
  comment = "#>"
)
options(tibble.print_min = 5)

## ----load---------------------------------------------------------------------
library(dplyr)
library(tsibble)
library(lubridate)

## -----------------------------------------------------------------------------
mth <- make_date("2018") + months(0:3)
tsibble(mth = mth, index = mth)

## -----------------------------------------------------------------------------
tsibble(mth = yearmonth(mth), index = mth)

## -----------------------------------------------------------------------------
x <- ymd_h("2015-04-05 01", tz = "Australia/Melbourne")
# base arithmetic respect tz
tsibble(time = x + (c(0, 3, 6, 9)) * 60 * 60, index = time)
# lubridate arithmetic doesn't respect tz
tsibble(time = x + hours(c(0, 3, 6, 9)), index = time)

## -----------------------------------------------------------------------------
tsbl1 <- tsibble(
  time = make_datetime(2018) + hours(0:3),
  station = "A",
  index = time, key = station
) %>% print()
tsbl2 <- tsibble(
  time = make_datetime(2018) + minutes(seq(0, 90, by = 30)),
  station = "B",
  index = time, key = station
) %>% print()
bind_rows(tsbl1, tsbl2)

## -----------------------------------------------------------------------------
x <- make_datetime(2018) + minutes(0:1)
tbl <- tibble(  
  time = c(x, x + minutes(15)),
  station = rep(c("A", "B"), 2)
)
as_tsibble(tbl, index = time, key = station)

## -----------------------------------------------------------------------------
tbl %>% 
  mutate(time = floor_date(time, unit = "15 mins")) %>% 
  as_tsibble(index = time, key = station)

