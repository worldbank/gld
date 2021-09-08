## ----initial, echo = FALSE, cache = FALSE, results = 'hide'-------------------
knitr::opts_chunk$set(
  warning = FALSE, message = FALSE, echo = TRUE,
  fig.width = 7, fig.height = 6, fig.align = 'centre',
  comment = "#>"
)
options(tibble.print_min = 5)

## ----ped----------------------------------------------------------------------
library(dplyr)
library(tsibble)
pedestrian

## ----has-gaps-----------------------------------------------------------------
has_gaps(pedestrian, .full = TRUE)

## ----count-gaps---------------------------------------------------------------
ped_gaps <- pedestrian %>% 
  count_gaps(.full = TRUE)
ped_gaps

## ----ggplot-gaps, fig.height = 3----------------------------------------------
library(ggplot2)
ggplot(ped_gaps, aes(x = Sensor, colour = Sensor)) +
  geom_linerange(aes(ymin = .from, ymax = .to)) +
  geom_point(aes(y = .from)) +
  geom_point(aes(y = .to)) +
  coord_flip() +
  theme(legend.position = "bottom")

## ----fill-na-default----------------------------------------------------------
ped_full <- pedestrian %>% 
  fill_gaps(.full = TRUE)
ped_full

## ----fill-na, eval = FALSE----------------------------------------------------
#  pedestrian %>%
#    fill_gaps(Count = 0L, .full = TRUE)
#  pedestrian %>%
#    group_by_key() %>%
#    fill_gaps(Count = mean(Count), .full = TRUE)

