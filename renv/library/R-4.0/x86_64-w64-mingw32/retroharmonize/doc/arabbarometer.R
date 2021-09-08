## ----vignette-setup, echo=FALSE, include=FALSE--------------------------------
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
retroharmonize::here() #imported from here::here()
current_year <- substr(as.character(Sys.Date()),1,4)
copyright_text <- ifelse (current_year == "2021", 
                          "\ua9 2021", 
                          paste0("\ua9 2021-", current_year))

## ----setup-knitr, include = FALSE---------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  fig.align='center',
  out.width = '85%',
  comment = "#>"
)

## ----load-pkgs, echo=FALSE, message=FALSE-------------------------------------
library(retroharmonize)
library(dplyr, quietly=TRUE)
library(tidyr)
library(ggplot2)
library(knitr)
load(file = system.file(
  # the first steps are saved becasue of 
  # large file/object sizes.
  "arabb", "arabb_vignette.rda", 
  package = "retroharmonize"))

## ----comparison-mena-elections-by-seleect-country-chart, fig.pos='center', out.width='85%'----
knitr::include_graphics(
  here('vignettes', 'arabb-comparison-select-country-chart.png')
)

## ----import, eval=FALSE-------------------------------------------------------
#  ### use here your own <arabbarometer_dir> directory
#  ab <- dir(arabbarometer_dir, pattern = "sav$")
#  arabbarometer_rounds <- here(arabbarometer_dir, ab)
#  arab_waves <- read_surveys(arabbarometer_rounds, .f='read_spss')

## ----wave-id, eval=FALSE------------------------------------------------------
#  # In the vignette this is pre-loaded.
#  attr(arab_waves[[1]],"id") <- "Arab_Barometer_5"
#  attr(arab_waves[[2]],"id") <- "Arab_Barometer_1"
#  attr(arab_waves[[3]],"id") <- "Arab_Barometer_2"
#  attr(arab_waves[[4]],"id") <- "Arab_Barometer_3"
#  attr(arab_waves[[5]],"id") <- "Arab_Barometer_4"

## ----save-arab_waves, include=FALSE, eval=FALSE-------------------------------
#  save(arab_waves, file = here("not_included", "arab_waves.rda"))

## ----document-arab-waves, eval=FALSE------------------------------------------
#  # In the vignette this is pre-loaded.
#  documented_arab_waves <- document_waves(arab_waves)

## ----print_documented_arab_waves----------------------------------------------
print(documented_arab_waves)

## ----create-arabb-metadata, eval=FALSE----------------------------------------
#  # In the vignette this is pre-loaded.
#  arabbarometer_metadata <- lapply ( X = arab_waves, FUN = metadata_create)
#  arabbarometer_metadata <- do.call(rbind, arabbarometer_metadata)

## ----random-review------------------------------------------------------------
set.seed(2021)
arabbarometer_metadata %>% 
  select (-all_of(c("filename", "class_orig"))) %>%
  sample_n(6)

## ----harmonize-elections-metadata---------------------------------------------
to_harmonize_elections <- arabbarometer_metadata %>%
  filter( .data$var_name_orig %in% c("rowid", "country","date", "wt")|
           grepl("how would you evaluate the last parliamentary", .data$label_orig)) %>%
  mutate(var_label = var_label_normalize(.data$label_orig)) %>%
  mutate(var_label = case_when(
    .data$var_name_orig == "country" ~ "Country",
    .data$var_name_orig == "rowid"   ~ "Unique ID AB English", # in pdf Unique ID AB English
    .data$var_name_orig == "date"    ~ "Date_of_interview",
    .data$var_name_orig == "wt"      ~ "Weight",
    TRUE ~ " Evaluation in the last parliamentary elections")) %>%
  mutate ( var_name = var_label_normalize(.data$var_label) )

set.seed(2021) # Let's see the same random example:
sample_n(to_harmonize_elections%>% 
       select ( all_of(c("id", "var_name", "var_label"))), 10)

## ----country-labels-example, include=FALSE------------------------------------
country_labels <- collect_val_labels (to_harmonize_elections %>% 
                      filter (.data$var_name == "country")) 

algeria_labels <- paste0("`", 
                         paste(country_labels[grepl("lgeria" , country_labels)], collapse = '`, `'), 
                         "`")

## ----merge-arabb-waves, eval=FALSE--------------------------------------------
#  # In the vignette this is pre-loaded.
#  merged_ab_elections <- merge_waves(
#    waves = arab_waves,
#    var_harmonization = to_harmonize_elections)

## ----to_harmonize_economy, include=FALSE, eval=FALSE--------------------------
#  to_harmonize_economy <- arabbarometer_metadata %>%
#    filter( .data$var_name_orig %in% c("rowid", "country","date", "wt")|
#             grepl("current economic situation", .data$label_orig)) %>%
#    mutate(var_label = var_label_normalize(.data$label_orig)) %>%
#    mutate(var_label = case_when(
#      .data$var_name_orig == "country" ~ "Country",
#      .data$var_name_orig == "rowid"   ~ "Unique ID AB English", # in pdf Unique ID AB English
#      .data$var_name_orig == "date"    ~ "Date_of_interview",
#      .data$var_name_orig == "wt"      ~ "Weight",
#      TRUE ~ "evaluation_economic_situation")) %>%
#    mutate (var_name = var_label_normalize(.data$var_label) )

## ----merged_ab_economic-to-save, include=FALSE, eval=FALSE--------------------
#  merged_ab_economic  <- merge_waves (
#    waves = arab_waves,
#    var_harmonization = to_harmonize_economy )
#  
#  merged_ab_economic  <- lapply ( merged_ab_economic,
#           FUN = function(x) x  %>%
#             mutate( country = normalize_country_names (country)))

## ----save-first-steps, include=FALSE, eval=FALSE------------------------------
#  # This saves the first steps because the object sizes are too large to be included with the package on CRAN.
#  save (merged_ab_elections, merged_ab_economic,
#        arabbarometer_metadata, documented_arab_waves,
#        file = here("inst", "arabb", "arabb_vignette.rda"))

## ----document-merged-ab-------------------------------------------------------
document_waves(merged_ab_elections)

## ----var-names----------------------------------------------------------------
lapply (merged_ab_elections, names)

## ----snakecase, message=FALSE-------------------------------------------------
library(snakecase)
merged_ab_elections  <- lapply(
  merged_ab_elections, 
  FUN = function(df) df %>%
                       rename_all(snakecase::to_snake_case)
  )

## ----var-names-2--------------------------------------------------------------
lapply(merged_ab_elections, names)

## ----remove-waves-------------------------------------------------------------
ab_elections <- merged_ab_elections[-c(1,2)]
lapply ( ab_elections, function(x)  attributes(x)$id )

## ----remove-date--------------------------------------------------------------
ab_elections <- lapply(ab_elections, function(x){
  if ("date_of_interview" %in% names(x)){
    subset(x, select = -c(date_of_interview))
  } else{
    subset(x)
  }
})

## ----print-remaining-waves----------------------------------------------------
document_waves(ab_elections)

## ----review-value-labels, eval=TRUE-------------------------------------------
collect_val_labels(
  to_harmonize_elections %>% 
     filter(grepl("evaluation in the last parliamentary elections", 
                  .data$var_name))
  )

## ----harmonize_arabb_eval-----------------------------------------------------
harmonize_arabb_eval <- function(x){
  label_list <- list(
    from = c("(\\d\\.\\s)?(\\w+\\s\\w+\\s)?([c|C]ompletely free and fair)",
             "(.+)(but)?\\s?(with)\\s(some)?\\s{0,}(minor\\s\\w+)",
             "(.+)(but)?\\s?(with)\\s(some)?\\s{0,}(major\\s\\w+)",
             "(.+)?([n|N]ot\\sfree\\s\\w+\\s\\w+)",
             "((\\d.\\s{0,})?\\si\\s)?([d|D]on.t\\sknow)(\\s\\(Do\\snot\\sread\\))?", 
             "[R|r]efuse", 
             "(\\d.\\s)?[d|D]ecline[d]?(\\s\\w+\\s\\w+)(\\s.Do not read.)?",
             "(\\d.\\s)?[m|M]issing"),
    to = c("free_and_fair", 
           "some_minor_problems",
           "some_major_problems",
           "not_free",
           "do_not_know","declined","declined","missing"),
    numeric_values = c(3,2,1,0,99997,99998,99998,99999))
  harmonize_values(x, harmonize_labels = label_list, 
                   na_values = c("do_not_know"= 99997,
                                 "declined"=99998,
                                 "missing"=99999
                   ))
}

## ----harmonize-evaluations, eval=TRUE-----------------------------------------
harmonized_evaluations <- harmonize_waves( 
  waves = lapply ( ab_elections, function(x) x %>% 
                     select (-.data$country)), 
  .f =harmonize_arabb_eval )

## ----country-label-problems---------------------------------------------------
country_labels <- collect_val_labels (to_harmonize_elections %>% 
                      filter (.data$var_name == "country")) 

country_labels[grepl("lgeria|orocco|oman" , country_labels)]

## ----normalize-country-names--------------------------------------------------
normalize_country_names <- function(x) { 
  x <- trimws(gsub("\\d{1,}\\.\\s?","", tolower(as_character(x))), which = "both")
  as_factor(snakecase::to_title_case(x))}

## ----harmonize-countries------------------------------------------------------
harmonize_countries <- lapply ( ab_elections, 
                                function(x) x %>% 
                                          select ( -.data$evaluation_in_the_last_parliamentary_elections)
                                )
harmonized_countries <- lapply ( harmonize_countries, function(x) x %>%
                mutate ( country = normalize_country_names(.data$country)) %>%
                select (-any_of("date_of_interview")))

harmonized_countries <- do.call (rbind, harmonized_countries)

## ----summarize-countries------------------------------------------------------
summary(harmonized_countries)

## ----summarize-evaluations----------------------------------------------------
summary(harmonized_evaluations)

## ----harmonized_ab_dataset----------------------------------------------------
harmonized_ab_dataset <- harmonized_countries  %>%
  left_join(harmonized_evaluations, by = c("unique_id_ab_english", "weight") ) %>%
  rename ( eval_parl = .data$evaluation_in_the_last_parliamentary_elections) %>%
  mutate ( 
    wave = as_factor(gsub(".*(\\b[A-Z0-9]+).*", "\\1", .data$unique_id_ab_english)),
    weight = ifelse(is.na(.data$weight), 1, .data$weight), 
    eval_parl = as_factor(.data$eval_parl), 
    country = as_factor(.data$country)) 

summary(harmonized_ab_dataset)

## ----categorical-valuation-summary, message=FALSE-----------------------------
categorical_summary <- harmonized_ab_dataset %>%
  select ( -all_of(c("unique_id_ab_english")) )  %>%
  group_by ( .data$country, .data$wave, .data$eval_parl ) %>%
  summarize (n = n(),
             weighted = round(n*weight, 0)
             ) %>%
  ungroup() 

## ----print-summary, eval=TRUE-------------------------------------------------
set.seed(2021)
categorical_summary %>% sample_n(12) 

## ----numeric-valuation-summary, messsage=FALSE--------------------------------
numeric_summary <- harmonized_ab_dataset %>%
  select ( -all_of(c("unique_id_ab_english")) )  %>%
  mutate ( eval_parl = as_numeric(.data$eval_parl)) %>%
  group_by ( .data$country, .data$wave ) %>%
  summarize (
    mean = weighted.mean(.data$eval_parl, w = .data$weight),
    median = median(.data$eval_parl)
  ) %>%
  ungroup() 

## ----print-numeric-summary----------------------------------------------------
set.seed(2021)
numeric_summary %>% sample_n(12) 

## ----comparison-chart, eval=FALSE, include=FALSE------------------------------
#  library(ggplot2)
#  
#  chart_caption <- paste0(copyright_text, " Daniel Antal, Ahmed Shaibani, retroharmonize.dataobservatory.eu/articles/arabbarometer.html")
#  summary_to_chart <- regional_parl_elections_by_wave  %>%
#    mutate ( wave = case_when (
#      .data$wave == "ABIII" ~ "Arab Barometer Wave 3 (2012/14)",
#      .data$wave == "ABIV" ~ "Arab Barometer Wave 4 (2016/17)",
#      .data$wave == "ABII" ~ "Arab Barometer Wave 2 (2010/11)"),
#      frequency =as.numeric(gsub("\\%", "", .data$freq)),
#      valuation = as_factor(snakecase::to_sentence_case(as_character(.data$valuation))) )
#  
#  valuation_palette <- c("#E88500", "#FAE000", "#BAC615", "#3EA135", "grey50", "grey70", "grey90")
#  names(valuation_palette) <- levels ( summary_to_chart$valuation)
#  
#  ggplot ( summary_to_chart,
#           aes ( x = valuation, y = frequency, group = wave, fill = valuation, label = freq )) +
#    geom_col() +
#    scale_y_continuous( limits = c(0,50) ) +
#    scale_fill_manual( values = valuation_palette ) +
#    facet_wrap(facets = "wave") +
#    geom_text(vjust = -0.28, size = 2.5) +
#    theme_classic() +
#    theme ( axis.text.x = element_blank(),
#            legend.position = 'bottom') +
#    labs ( x = NULL, y = "Relative Frequency (freq)",
#           title = "Comparison of Arab Barometer Election Valuations",
#           caption = chart_caption )

## ----save-chart, include=FALSE, eval=FALSE------------------------------------
#  ggsave (here('vignettes', 'arabb-comparison-chart.png'), unit = "cm", width =16*1.2, height=9*1.2, dpi =200)

## ----comparison-mena-elections-chart, fig.pos='center', out.width='85%'-------
knitr::include_graphics(
  here('vignettes', 'arabb-comparison-chart.png')
)

## ----regional_parl_elections_by_country, include=FALSE, eval=FALSE------------
#  regional_parl_elections_by_country <- harmonized_ab_dataset %>%
#    select(
#      -all_of(c("weight", "unique_id_ab_english"))
#      )%>%
#    mutate (
#      eval_parl =
#        as_factor(eval_parl)) %>%
#    pivot_longer ( starts_with("eval"),
#                   names_to  = "indicator",
#                   values_to = "valuation") %>%
#    filter ( !is.na(.data$valuation)) %>%
#        group_by(.data$wave,.data$valuation, .data$country) %>%
#    summarize(n=n())%>%
#    mutate(freq= paste0(round(100 * n/sum(n), 0), "%")) %>%
#    ungroup() %>%
#    filter ( !is.na(n))

## ----regional_parl_elections_by_country-plot, include=FALSE, eval=FALSE-------
#  summary_to_country_chart <- regional_parl_elections_by_country  %>%
#    filter ( .data$wave != "ABI" ) %>%
#     mutate ( wave = case_when (
#      .data$wave == "ABIII" ~ "Wave 3 (2012/14)",
#      .data$wave == "ABIV" ~ "Wave 4 (2016/17)",
#      .data$wave == "ABII" ~ "Wave 2 (2010/11)"),
#      frequency =as.numeric(gsub("\\%", "", .data$freq)),
#      valuation = as_factor(snakecase::to_sentence_case(as_character(.data$valuation)))
#      ) %>%
#    mutate ( frequency = ifelse (is.na(.data$frequency), 0, .data$frequency))
#  
#  create_country_chart <- function(dat, title = "Comparison of Arab Barometer Election Valuations",
#                                   subtitle = "Breakup by Country and Survey Wave") {
#    ggplot ( dat,
#           aes ( x = valuation,
#                 y = frequency,
#                 group = country,
#                 fill = valuation, label = freq )) +
#    geom_col() +
#    scale_y_continuous( limits = c(0,40)) +
#    scale_fill_manual( values = valuation_palette ) +
#    facet_grid( rows = vars(country), cols = vars(wave), scales = "fixed") +
#    geom_text(vjust = -0.28, size = 2) +
#    #theme_minimal() +
#    theme ( axis.text.x = element_blank(),
#            axis.text.y = element_blank(),
#            axis.ticks = element_blank(),
#            strip.text.x = element_text(size = 5),
#            strip.text.y = element_text(size = 4),
#            plot.title = element_text(size=11),
#            plot.subtitle = element_text(size=8),
#            plot.caption =  element_text (size=5),
#            legend.text = element_text(size=5),
#            axis.title = element_text(size=8),
#            legend.position = 'bottom') +
#    labs ( x = NULL, y = "Relative Frequency (freq)", fill = NULL,
#           title = title,
#           subtitle = subtitle,
#           caption = chart_caption )
#  }
#  
#  create_country_chart(summary_to_country_chart)

## ----save-chart-by-country, include=FALSE, eval=FALSE-------------------------
#  ggsave (here('vignettes', 'arabb-comparison-country-chart.png'), unit = "cm", width = 10, height=15, dpi =200)

## ----comparison-mena-elections-by-country-chart, fig.pos='center', out.width='85%'----
knitr::include_graphics(
  here('vignettes', 'arabb-comparison-country-chart.png')
)

## ----arabb-comparison-select-country-chart, include=FALSE, eval=FALSE---------
#  create_country_chart(
#    summary_to_country_chart %>%
#      filter ( ! .data$country %in% c("Kuwait", "Libya", "Iraq", "Yemen", "Morocco", "Sudan")),
#    subtitle = "Select Countries (Present In All Three Waves)")

## ----save-chart-by-select-country, include=FALSE, eval=FALSE------------------
#  ggsave (here('vignettes', 'arabb-comparison-select-country-chart.png'), unit = "cm", width = 15, height=10, dpi =300)

## ----save-basic-types---------------------------------------------------------
harmonized_ab_data <- harmonized_ab_dataset %>% 
  rename ( id = .data$unique_id_ab_english ) %>%
  mutate (eval_parl_num = as_numeric(.data$eval_parl), 
          eval_parl_cat = as_factor(.data$eval_parl)) %>%
  select (all_of(c("id", "country", "eval_parl_num", "eval_parl_cat", "wave")))

## ----save-replication-data, eval=FALSE----------------------------------------
#  haven::write_sav(data = harmonized_ab_data,
#                   here("data-raw", "arabb", "harmonized_arabb_waves.sav"))
#  write.csv(harmonized_ab_data,
#            here("data-raw", "arabb", "harmonized_arabb_waves.csv"),
#            row.names=FALSE)
#  write.csv(categorical_summary,
#            here("data-raw", "arabb",  "arabb_categorical_summary.csv"),
#            row.names=FALSE)
#  write.csv(numeric_summary,
#            here("data-raw", "arabb", "arabb_numeric_summary.csv"),
#            row.names=FALSE)
#  
#  # The metadata file contains list objects, which cannot be represented
#  # in a flat csv file format.
#  saveRDS(arabbarometer_metadata,
#          here("data-raw", "arabb", "arabbarometer_metadata.rds")
#          )
#  
#  ## The lists of value labels are dropped from the csv output.
#  write.csv(arabbarometer_metadata [
#    , -which (sapply ( arabbarometer_metadata, class) == "list")],
#    here("data-raw", "arabb","arabb_metadata_simplified.csv"), row.names=FALSE)

## ----citation-regions, message=FALSE, eval=TRUE, echo=TRUE--------------------
citation("retroharmonize")

## ----sessioninfo, message=FALSE, warning=FALSE--------------------------------
sessionInfo()

