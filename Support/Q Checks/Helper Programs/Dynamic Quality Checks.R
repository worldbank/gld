#=========================================================================#
# This code serves as the dynamic variable check for the GLD.
# The user needs to load the correct data they want to inspect. After
# that they can run the app. The user interface allows the user to evaluate
# the percentage of specific categorical variables and select which years
# to select from.
#=========================================================================#

library(tidyverse)
library(scales)
library(shiny)

#=========================================================================#
# Step 1 - Define where .dta files stored ---------------------------------
#=========================================================================#

# Clean up at the start
rm(list=ls())

# User to define which dta files should be analysed.
eval_directory <- PHL     # replace this with top-level country directory path
 


### ============================================ ###
### From here on, the file should run on its own ###
### ============================================ ###
 
paths <- list.files(eval_directory,     
                    pattern = "\\GLD_ALL.dta$", # "\\.dta$"
                    recursive = TRUE,   # search all sub folders
                    full.names = TRUE,  # list full file names
                    include.dirs = TRUE) # include the full file path



#=========================================================================#
# Step 3 - Load files defined in paths ------------------------------------
#=========================================================================#

# Create an empty list to fill with files
file_list <- list()

for (i in seq_along(paths)){ 
  
  # For each path, add a list entry with the read data frame
  file_list[[names(paths)[i]]] <- read_dta(paths[[i]])
  
}

# Bind all data frames into a single object
df <- bind_rows(file_list) 

#=========================================================================#
# Step 4 - Define necessary objetcs and functions to run program ----------
#=========================================================================#

# Define variables to be inspected
variables <- c("educat7", "educat5", "educat4", "educat_isced", "hsize",
               "industrycat10", "industrycat4", "industrycat10_2", "industrycat4_2",
               "industrycat10_year", "industrycat4_year", "industrycat10_2_year", "industrycat4_2_year")

# Define years to be inspected
years <- unique(df$year)

# Based on the number of years, determine the number of rows (up to 5 in a row, 6 to 11 2 rows, ...)
rows <- (length(years)%/%6) + 1

# Function to make weighted category percentages
calc_pct <- function(data, vars){
  
  # Create list to hold each iteration
  list_collect <- list()
  
  # Loop through variables
  for (var in vars){
    
    # Only run if variable to check is in the data frame
    if (var %in% names(data)){
      
      # Create DF that has weighted percentages
      out <- data %>% group_by(year) %>% 
        count(.data[[var]], wt = weight) %>% 
        filter(!is.na(.data[[var]])) %>% 
        mutate(tot = sum(n), pct = n/tot) %>%
        rename(values = .data[[var]])
      # Add it to list
      list_collect[[var]] <- out      
      
    }

  }
  
  # Bind rows, add column "var" to determine which variable
  result <- bind_rows(list_collect, .id = "var")
  return(result)
  
}

# Apply calc_pct to df
weighted_df <- df %>% calc_pct(vars = variables)

# Function to draw lines
plot_lines <- function(data, variable, years, rows){
  
  plot <- data %>% 
    filter(var == variable) %>% # Reduce to variable selected 
    filter(year %in% years) %>% # Reduce to years selected
    ggplot(aes(x=factor(values), y=pct, group=factor(year), color=factor(year))) +
    geom_line() +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) + 
    labs(y = "Percentage of non missing answers", x = variable, title = "", color = "Year(s)") +
    theme(legend.position = "bottom") +
    guides(colour = guide_legend(nrow = rows))
  
  return(plot)
  
}



#=========================================================================#
# Step 5 - Define the UI for the application ------------------------------
#=========================================================================#
ui <- fluidPage(
  
  # Application title
  titlePanel("Dynamic Checks"),
  
  # Variables Menu
  selectInput("vars", "Choose variable", weighted_df$var),
  
  # Years Menu
  checkboxGroupInput("years", "Choose years", choices = years, selected = years),
  
  # Line Chart - Density Lines, short dl
  plotOutput("dl")
  
)



#=========================================================================#
# Step 6 - Define server logic --------------------------------------------
#=========================================================================#
server <- function(input, output) {
  
  # Create line chart of categories
  output$dl <- renderPlot({
    
    weighted_df %>% plot_lines(variable = input$vars, years = input$years, rows = rows)
    
  })
  
}

#=========================================================================#
# Step 7 - Run the application --------------------------------------------
#=========================================================================#
shinyApp(ui = ui, server = server)

