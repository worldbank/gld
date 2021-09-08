## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(retroharmonize)

## -----------------------------------------------------------------------------
v1 <- labelled_spss_survey (
  c(1,0,1,9), 
  labels = c("yes" =1,
             "no" = 0,
             "inap" = 9),
  na_values = 9)

h1 <- harmonize_values(
  x = v1, 
  harmonize_labels = list(
    from = c("^yes", "^no", "^inap"), 
    to = c("trust", "not_trust", "inap"), 
    numeric_values = c(1,0,99999)), 
  id = "survey1")

str(h1)

## -----------------------------------------------------------------------------
v2 <- haven::labelled_spss (
  c(1,1,0,8), 
  labels = c("yes" = 1,
             "no"  = 0,
             "declined" = 8),
  na_values = 8)

h2 <- harmonize_values(
  v2, 
  harmonize_labels = list(
    from = c("^yes", "^no", "^inap"), 
    to = c("trust", "not_trust", "inap"), 
    numeric_values = c(1,0,99999)), 
  id = 'survey2' )
str(h2)

## -----------------------------------------------------------------------------
h2b <- harmonize_values(
  v2, 
  harmonize_labels = list(
    from = c("^yes", "^no", "^decline"), 
    to = c("trust", "not_trust", "inap"), 
    numeric_values = c(1,0,99999)), 
  id = 'survey2' )

str(h2b)

## -----------------------------------------------------------------------------
var3 <- labelled::labelled(
  x = c(1,6,2,9,1,1,2), 
  labels = c("Tend to trust" = 1, 
             "Tend not to trust" = 2, 
             "DK" = 6))

h3 <- harmonize_values(
  x = var3, 
  harmonize_labels = list ( 
    from = c("^tend\\sto|^trust",
             "^tend\\snot|not\\strust", "^dk",
             "^inap"), 
    to = c("trust", 
           "not_trust", "do_not_know", 
           "inap"),
    numeric_values = c(1,0,99997, 99999)
  ), 
  id = "S3_")

str(h3)

## -----------------------------------------------------------------------------
summary(as_factor(h3))
levels(as_factor(h3)) 
unique(as_factor(h3))

## -----------------------------------------------------------------------------
summary(as_numeric(h3))
unique(as_numeric(h3))

## -----------------------------------------------------------------------------
summary(as_character(h3))
unique(as_character(h3))

## -----------------------------------------------------------------------------
var1 <- labelled::labelled_spss(
  x = c(1,0,1,1,0,8,9), 
  labels = c("TRUST" = 1, 
             "NOT TRUST" = 0, 
             "DON'T KNOW" = 8, 
             "INAP. HERE" = 9), 
  na_values = c(8,9))

var2 <- labelled::labelled_spss(
  x = c(2,2,8,9,1,1 ), 
  labels = c("Tend to trust" = 1, 
             "Tend not to trust" = 2, 
             "DK" = 8, 
             "Inap" = 9), 
  na_values = c(8,9)
  )


h1 <- harmonize_values (
  x = var1, 
  harmonize_label = "Do you trust the European Union?",
  harmonize_labels = list ( 
    from = c("^tend\\sto|^trust", "^tend\\snot|not\\strust", "^dk|^don", "^inap"), 
    to = c("trust", "not_trust", "do_not_know", "inap"),
    numeric_values = c(1,0,99997, 99999)), 
  na_values = c("do_not_know" = 99997,
                "inap" = 99999), 
  id = "survey1"
  )

h2 <- harmonize_values (
  x = var2, 
  harmonize_label = "Do you trust the European Union?",
  harmonize_labels = list ( 
    from = c("^tend\\sto|^trust", "^tend\\snot|not\\strust", "^dk|^don", "^inap"), 
    to = c("trust", "not_trust", "do_not_know", "inap"),
    numeric_values = c(1,0,99997, 99999)), 
  na_values = c("do_not_know" = 99997,
                "inap" = 99999), 
  id = "survey2"
)


## -----------------------------------------------------------------------------
vctrs::vec_c(h1,h2)

## -----------------------------------------------------------------------------
a <- tibble::tibble ( rowid = paste0("survey1", 1:length(h1)),
                      hvar = h1, 
                      w = runif(n = length(h1), 0,1))
b <- tibble::tibble ( rowid = paste0("survey2", 1:length(h2)),
                      hvar  = h2, 
                      w = runif(n = length(h2), 0,1))

c <- dplyr::bind_rows(a, b)

## -----------------------------------------------------------------------------
summary(c)

## -----------------------------------------------------------------------------
print(c)

