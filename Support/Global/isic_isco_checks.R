# isic_isco_check.R
# Checks isic and isco non-missing values by year. Assumes you run main.R
library(tidyverse)

load(file = file.path(PHL, "PHL_data/GLD/population.Rdata"))
     

#check isic and isco
sum(!is.na(phl$industrycat_isic))/nrow(phl) # 0.3650861 of cases are non missing
sum(!is.na(phl$occup_isco))/nrow(phl) # 0.3576665 of cases are nonmissing

sum.isic.isco <- phl %>%
  group_by(year) %>%
  summarize(industry_pct = sum(!is.na(industrycat_isic))/n(),
            occup_pct    = sum(!is.na(occup_isco))/n()
            )

save(
  sum.isic.isco,
  file = file.path(PHL, "PHL_data/GLD/isic_isco_summary.Rdata")
)
