## ---- echo = FALSE, include=FALSE---------------------------------------------
## https://github.com/tidyverse/rvest/blob/master/vignettes/selectorgadget.Rmd
requireNamespace("png", quietly = TRUE)
embed_png <- function(path, dpi = NULL) {
  meta <- attr(png::readPNG(path, native = TRUE, info = TRUE), "info")
  if (!is.null(dpi)) meta$dpi <- rep(dpi, 2)
  knitr::asis_output(paste0(
    "<img src='", path, "'",
    " width=", round(meta$dim[1] / (meta$dpi[1] / 96)),
    " height=", round(meta$dim[2] / (meta$dpi[2] / 96)),
    " />"
  ))
}

## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(retroharmonize)
library(dplyr)
library(tidyr)
load(file = system.file(
  "afrob", "afrob_vignette.rda", 
  package = "retroharmonize"))

## ----setup, eval=FALSE--------------------------------------------------------
#  library(retroharmonize)
#  library(dplyr)
#  library(tidyr)

## ----import, eval=FALSE-------------------------------------------------------
#  ### use here your own directory
#  ab <- dir ( afrobarometer_dir )
#  afrobarometer_rounds <- file.path(afrobarometer_dir, ab)
#  
#  ab_waves <- read_surveys(afrobarometer_rounds, .f='read_spss')

## ----set-id, eval=FALSE-------------------------------------------------------
#  attr(ab_waves[[1]], "id") <- "Afrobarometer_R5"
#  attr(ab_waves[[2]], "id") <- "Afrobarometer_R6"
#  attr(ab_waves[[3]], "id") <- "Afrobarometer_R7"

## ----document-ab, eval=FALSE--------------------------------------------------
#  documented_ab_waves <- document_waves(ab_waves)

## -----------------------------------------------------------------------------
print(documented_ab_waves)

## ----create-metadata, eval=FALSE----------------------------------------------
#  ab_metadata <- lapply ( X = ab_waves, FUN = metadata_create )
#  ab_metadata <- do.call(rbind, ab_metadata)

## ---- selection, eval=FALSE---------------------------------------------------
#  library(dplyr)
#  to_harmonize <- ab_metadata %>%
#    filter ( var_name_orig %in%
#               c("rowid", "DATEINTR", "COUNTRY", "REGION", "withinwt") |
#               grepl("trust ", label_orig ) ) %>%
#    mutate ( var_label = var_label_normalize(label_orig)) %>%
#    mutate ( var_label = case_when (
#      grepl("^unique identifier", var_label) ~ "unique_id",
#      TRUE ~ var_label)) %>%
#    mutate ( var_name = val_label_normalize(var_label))

## -----------------------------------------------------------------------------
to_harmonize <- to_harmonize %>%
  filter ( 
    grepl ( "president|parliament|religious|traditional|unique_id|weight|country|date_of_int", var_name)
    )

## -----------------------------------------------------------------------------
head(to_harmonize %>%
       select ( all_of(c("id", "var_name", "var_label"))), 10)

## ----merge, eval=FALSE--------------------------------------------------------
#  merged_ab <- merge_waves ( waves = ab_waves,
#                             var_harmonization = to_harmonize  )
#  
#  # country will be a character variable, and doesn't need a label
#  merged_ab <- lapply ( merged_ab,
#           FUN = function(x) x  %>%
#             mutate( country = as_character(country)))

## ---- eval=FALSE--------------------------------------------------------------
#  documenteded_merged_ab <- document_waves(merged_ab)

## -----------------------------------------------------------------------------
print(documenteded_merged_ab)

## ----check, eval=FALSE--------------------------------------------------------
#  R6 <- pull_survey ( merged_ab, id = "Afrobarometer_R6" )

## ----pulled-attributes--------------------------------------------------------
attributes(R6$trust_president[1:20])

## ----document-item------------------------------------------------------------
document_survey_item(R6$trust_president)

## -----------------------------------------------------------------------------
collect_na_labels( to_harmonize )

## -----------------------------------------------------------------------------
collect_val_labels (to_harmonize %>%
                      filter ( grepl( "trust", var_name) ))

## ----specify------------------------------------------------------------------
harmonize_ab_trust <- function(x) {
  label_list <- list(
    from = c("^not", "^just", "^somewhat",
             "^a", "^don", "^ref", "^miss", "^not", "^inap"), 
    to = c("not_at_all", "little", "somewhat", 
           "a_lot", "do_not_know", "declined", "inap", "inap", 
           "inap"), 
    numeric_values = c(0,1,2,3, 99997, 99998, 99999,99999, 99999)
  )
  
  harmonize_values(
    x, 
    harmonize_labels = label_list, 
    na_values = c("do_not_know"=99997,
                  "declined"=99998,
                  "inap"=99999)
  )
}

## ----harmonize, eval=FALSE----------------------------------------------------
#  harmonized_ab_waves <- harmonize_waves (
#    waves = merged_ab,
#    .f = harmonize_ab_trust )

## ---- eval=FALSE--------------------------------------------------------------
#  h_ab_structure <- attributes(harmonized_ab_waves)

## -----------------------------------------------------------------------------
h_ab_structure$row.names <- NULL # We have over 100K row names
h_ab_structure

## ----year, eval=FALSE---------------------------------------------------------
#  harmonized_ab_waves <- harmonized_ab_waves %>%
#    mutate ( year = as.integer(substr(as.character(
#      date_of_interview),1,4)))

## ---- eval=FALSE--------------------------------------------------------------
#  harmonized_ab_waves <- harmonized_ab_waves %>%
#    filter ( country %in% c("Niger", "Nigeria", "Algeria",
#                            "South Africa", "Madagascar"))

## ----numeric------------------------------------------------------------------
harmonized_ab_waves %>%
  mutate_at ( vars(starts_with("trust")), 
              ~as_numeric(.)*within_country_weighting_factor) %>%
  select ( -all_of("within_country_weighting_factor") ) %>%
  group_by ( country, year ) %>%
  summarize_if ( is.numeric, mean, na.rm=TRUE ) 

## ----factor-------------------------------------------------------------------
library(tidyr)  ## tidyr::pivot_longer()
harmonized_ab_waves %>%
  select ( -all_of("within_country_weighting_factor") ) %>%
  mutate_if ( is.labelled_spss_survey, as_factor) %>%
  pivot_longer ( starts_with("trust"), 
                        names_to  = "institution", 
                        values_to = "category") %>%
  mutate ( institution = gsub("^trust_", "", institution) ) %>%
  group_by ( country, year, institution, category ) %>%
  summarize ( n = n() ) 

## ---- out.width='95%', echo=FALSE---------------------------------------------
knitr::include_graphics('ab_plot1.png')

