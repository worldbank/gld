## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE,
                      comment = "#>",
                      collapse = TRUE
                      )

## ------------------------------------------------------------------------
string <- c("lowerCamelCase", "ALL_CAPS", "IDontKNOWWhat_thisCASE_is")

## ------------------------------------------------------------------------
library(snakecase)
to_snake_case(string)

## ------------------------------------------------------------------------
to_mixed_case(string, sep_out = " ")

## ------------------------------------------------------------------------
to_snake_case(string, sep_out = ".")
to_snake_case(string, sep_out = "-")

## ------------------------------------------------------------------------
to_screaming_snake_case(string, sep_out = "=")

## ------------------------------------------------------------------------
to_upper_camel_case(string)

## ------------------------------------------------------------------------
library(magrittr)
to_any_case(c("SomeBAdInput", "someGoodInput")) %>% dput()

