## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(retroharmonize)
load(file = system.file(
  "eurob", "eurob_vignette.rda", package = "retroharmonize"))

## ----setup, message=FALSE-----------------------------------------------------
library(retroharmonize)
library(dplyr)

## ----import-display, eval=FALSE-----------------------------------------------
#  eurobarometer_waves <- file.path("working", dir("working"))
#  eb_waves <- read_surveys(eurobarometer_waves, .f='read_rds')

## ----import-here, echo=FALSE--------------------------------------------------
working_dir  <- here::here("working")
eurobarometer_waves <- file.path(working_dir, dir(working_dir))
eb_waves <- read_surveys(eurobarometer_waves, .f='read_rds')

## ----document-waves, eval=FALSE-----------------------------------------------
#  documented_eb_waves <- document_waves(eb_waves)

## ----metadata, eval=FALSE-----------------------------------------------------
#  eb_trust_metadata <- lapply ( X = eb_waves, FUN = metadata_create )
#  eb_trust_metadata <- do.call(rbind, eb_trust_metadata)
#  #let's keep the example manageable:
#  eb_trust_metadata  <- eb_trust_metadata %>%
#    filter ( grepl("parliament|commission|rowid|weight_poststrat|country_id", var_name_orig) )

## ----head---------------------------------------------------------------------
head(eb_trust_metadata)

## ----valid-labels-------------------------------------------------------------
collect_val_labels(eb_trust_metadata)

## ----missing-labels-----------------------------------------------------------
collect_na_labels(eb_trust_metadata)

## -----------------------------------------------------------------------------
## You will likely use your own local working directory, or
## tempdir() that will create a temporary directory for your 
## session only. 
working_directory <- tempdir()

## ----subsetting, eval=FALSE---------------------------------------------------
#  # This code is for illustration only, it is not evaluated.
#  # To replicate the worklist, you need to have the SPSS file names
#  # as a list, and you have to set up your own import and export path.
#  
#  selected_eb_metadata <- readRDS(
#    system.file("eurob", "selected_eb_waves.rds", package = "retroharmonize")
#    ) %>%
#    mutate ( id = substr(filename,1,6) ) %>%
#    rename ( var_label = var_label_std ) %>%
#    mutate ( var_name = var_label )
#  
#  ## This code is not evaluated, it is only an example. You are likely
#  ## to have a directory where you have already downloaded the data
#  ## from GESIS after accepting their term use.
#  
#  subset_save_surveys (
#    var_harmonization = selected_eb_metadata,
#    selection_name = "trust",
#    import_path = gesis_dir,
#    export_path = working_directory )

## ----specificfunction---------------------------------------------------------
harmonize_eb_trust <- function(x) {
  label_list <- list(
    from = c("^tend\\snot", "^cannot", "^tend\\sto", "^can\\srely",
             "^dk", "^inap", "na"), 
    to = c("not_trust", "not_trust", "trust", "trust",
           "do_not_know", "inap", "inap"), 
    numeric_values = c(0,0,1,1, 99997,99999,99999)
  )

  harmonize_values(x, 
                   harmonize_labels = label_list, 
                   na_values = c("do_not_know"= 99997,
                                 "declined"   = 99998,
                                 "inap"       = 99999 )
  )
}

## ---- eval=FALSE--------------------------------------------------------------
#  document_waves(eb_waves)

## ---- echo=FALSE--------------------------------------------------------------
documented_eb_waves

## ---- check, eval=FALSE-------------------------------------------------------
#  test_trust <- pull_survey(eb_waves, filename = "ZA4414_trust.rds")

## ---- pulled-check------------------------------------------------------------
test_trust$trust_european_commission[1:16]

## -----------------------------------------------------------------------------
harmonize_eb_trust(test_trust$trust_european_commission[1:16])

## -----------------------------------------------------------------------------
eb_waves_selected <- lapply ( eb_waves, function(x) x %>% select ( 
  any_of (c("rowid", "country_id", "weight_poststrat", 
            "trust_national_parliament", "trust_european_commission", 
            "trust_european_parliament"))) %>%
    filter ( country_id %in% c("NL", "PL", "HU", "SK", "BE", 
                               "MT", "IT")))


## ----harmonizewaves, eval=FALSE-----------------------------------------------
#  harmonized_eb_waves <- harmonize_waves (
#    waves = eb_waves_selected,
#    .f = harmonize_eb_trust )

## -----------------------------------------------------------------------------
wave_attributes <- attributes(harmonized_eb_waves)
wave_attributes$id
wave_attributes$filename
wave_attributes$names

## ----factor-------------------------------------------------------------------
harmonized_eb_waves %>%
  mutate_at ( vars(contains("trust")), as_factor ) %>%
  summary()

## ----numericrepr--------------------------------------------------------------
numeric_harmonization <- harmonized_eb_waves %>%
  mutate_at ( vars(contains("trust")), as_numeric )
summary(numeric_harmonization)

## -----------------------------------------------------------------------------
numeric_harmonization %>%
  group_by(country_id) %>%
  summarize_at ( vars(contains("trust")), list(~mean(.*weight_poststrat, na.rm=TRUE))) 

