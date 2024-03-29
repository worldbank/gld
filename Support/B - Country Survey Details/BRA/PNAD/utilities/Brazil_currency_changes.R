
# The object "df" we start with is the result of appending the GLD files for all years, not shown here.


# Step 1 - Create relevant data sets --------------------------------------

# Create mean wage data from 1981 to 1998 for employees with wage info, as is (pure nominal values)
wage_as_is <- 
  df %>% 
  filter(empstat == 1) %>%
  filter(!is.na(wage_no_compen)) %>%
  filter(year < 1999) %>%
  group_by(year) %>%
  summarise(
    mean_employee_wage = round(mean(wage_no_compen), 0)
)

# Create currency change data frame
currency <- tibble::tibble(
  start    = c(1981, 1985.5, 1988.5, 1992.5, 1993.5),
  end      = c(1985.5, 1988.5, 1992.5, 1993.5, 1998),
  Currency =  c("Cruzerio", "Cruzado", "Cruzado Novo", "Cruzeiro\nReal", "Real")
)

# Read in CPI data
url <- glue::glue("https://api.worldbank.org/v2/country/BRA/indicator/FP.CPI.TOTL?per_page=999&format=json")
cpi <- jsonlite::fromJSON(url)[[2]]
base_year <- cpi$date[cpi$value %in% 100]
cpi <- cpi %>% select(year = date, value) %>% mutate(year = as.numeric(year))

# Create mean wage data from 1981 to 1998 for employees unified with the currency 
wage_unif <- df %>%
  filter(empstat == 1) %>%
  filter(!is.na(wage_no_compen)) %>%
  filter(year < 1999) %>%
  mutate(
    unified_wage = case_when(
      year < 1986 ~ wage_no_compen/2750/1000/1000/1000,
      between(year, 1986, 1988) ~ wage_no_compen/2750/1000/1000,
      between(year, 1989, 1992) ~ wage_no_compen/2750/1000,
      year == 1993 ~ wage_no_compen/2750,
      year > 1993 ~ wage_no_compen
    )) %>%
  group_by(year) %>%
  summarise(
    mean_employee_wage = mean(unified_wage)  )

# Apply CPI to unified wage data
df_w_cpi <-
  
  left_join(wage_unif, cpi, by = "year") %>%
  
  # Deflate all wage info vars (all start with <<w_>>)
  mutate(
    mean_employee_wage = mean_employee_wage/(value/100),
    # Add CPI base year
    cpi_base = base_year,
    # Add variable of interest (wage)
    var = "Hourly wage"
  )


# Step 2 - Plot nominal values --------------------------------------------

ggplot(wage_as_is) +
  
  geom_rect(
  aes(xmin = start, xmax = end, fill = Currency), 
  ymin = -Inf, ymax = Inf, alpha = 0.2, 
  data = currency) +
  
  geom_vline(
    aes(xintercept = as.numeric(start)), 
    data = currency,
    colour = "grey50", alpha = 0.5
  ) + 
  
  geom_text(
    aes(x = start, y = 1294482, label = Currency),
    data = currency,
    size = 5, vjust = 0, hjust = 0, nudge_x = c(0.1, 0.1, 0.1, 0.1, 1.5),
    nudge_y = c(0,0,0,-0.19,0) ) +
  
  geom_line(aes(year, mean_employee_wage)) +
  geom_point(aes(year, mean_employee_wage)) +
  scale_y_continuous(trans='log10',
                     labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
  scale_x_continuous(breaks = seq(1981,1998,1)) + 
  guides(fill = "none") +
  labs(y = "Mean monthly employee wage (log10 scale)", x = "Year") 



# Step 3 - Plot unified, deflated values ----------------------------------

ggplot(df_w_cpi) +
  
  geom_rect(
    aes(xmin = start, xmax = end, fill = Currency), 
    ymin = -Inf, ymax = Inf, alpha = 0.2, 
    data = currency) +
  
  geom_vline(
    aes(xintercept = as.numeric(start)), 
    data = currency,
    colour = "grey50", alpha = 0.5
  ) + 
  
  geom_text(
    aes(x = start, y = 1200, label = Currency),
    data = currency,
    size = 5, vjust = 0, hjust = 0, nudge_x = c(2.8, 1.2, 1, 0.1, 3.5),
    nudge_y = c(0,0,0,-14,0) ) +
  
  geom_line(aes(year, mean_employee_wage)) +
  geom_point(aes(year, mean_employee_wage)) +
  # scale_y_continuous(trans='log10',
  #                    labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
  scale_x_continuous(breaks = seq(1981,1998,1)) + 
  guides(fill = "none") +
  labs(y = "Mean monthly employee wage", x = "Year") 
