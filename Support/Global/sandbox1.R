read_pdf2 <- function(pdf_path, page_min, page_max, 
                     
                     header = TRUE,
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     xlabel = c(155, 420),
                     xmin = c(91, 131, 415, 446, 501),
                     xmax = c(130, 175, 445, 500, 9999),
                     numlist = NULL
                     
) {
  
  
  
  
  
  # define 1st sub-function to import the table
  import_table_pdf <- function( page, ... ) {
    
    
    # define 2nd sub-function that extracts column info from partially-processed data
    col_info <- function(data_in, ...) { # x_min, x_max, var_name
      
      col <- data_in %>%
        filter(x >= ..1 & x < ..2) %>% # 1 = xmin, 2 = xmax
        select(text, y) %>%
        mutate(varname = as.character(..3))
      
      return(col)
    }
    
    
    
    ##### Data work #####
    
    
    nvars <- length(varnames)
    
    
    # note: we could read the data directly from pdftools each time but that's computationally
    # expensive. It's better to read in the whole pdf as one object outside the function and 
    # call the object from outside the function -- until I can figure out a more elegant way 
    # to do this in the function itself.
    
    # subset data loaded by pdftools
    data <- pdf[[page]] # old
    
    
    data_tib <- data %>%
      filter(x < xlabel[1] | x > xlabel[2]) %>%
      mutate(str = str_detect(text, "[:alpha:]+$")) %>%
      filter(str == FALSE) %>%
      select(x, y, text) 
    
    
    # if header==TRUE, remove page titles; if no data, no obs.
    if (header == TRUE) {
      data_tib <- data_tib %>%
        filter(y >= ymin)
    }
    
    # if header==FALSE, keep only numbers, and remove specified number args
    if (header == FALSE) {
      data_tib <- data_tib %>%
        mutate(str = str_detect(text, "^[:alpha:]+")) %>%
        filter(str == FALSE) %>%
        select(-str) %>%
        filter(((text %in% numlist) & y < ymin) == FALSE) # y >= ymin
    }
    
    
    
    
    # create a tibble as a shorthand for the pmap function
    purrr.tib <- tibble(x_min = xmin, 
                        x_max = xmax,
                        var_names = varnames,
                        num = seq(1,nvars))
    
    
    # append all the elements in a tabular version
    els <- pmap( purrr.tib, # these args get passed/walked along in sequence
                 col_info,
                 data_in = data_tib # this arg does not.
    )
    
    els <- do.call(rbind, els)
    
    table <- els %>%
      filter(!grepl("^p;", text)) %>% # these characters mess up the columns, must 
      filter(!grepl("\\(", text)) %>% # remove here 
      filter(!grepl("\\)", text)) %>% 
      mutate(text = case_when(is.null(text) ~ NA_character_,
                              TRUE ~ text)) 
      # group_by(y) %>%
      # mutate(page_grp = cur_group_id(),
      #        page = page) 
      # pivot_wider(names_from = "varname",
      #             values_from= "text")
    
    
    
    return(table)
    
  }
  
  
  ## Import the PDF with pdftools 
  pdf <- pdftools::pdf_data(pdf_path) 
  
  
  ## perform the function call with purrr 
  raw <- pmap(list(page_min:page_max), import_table_pdf)
  raw <- do.call(rbind, raw)
  
  return(raw)
  
}


nearest_neighbor <- function(x, # input row's y (single value)
                       y, # whole y column (whole col)
                       tol=1) {
  
  # find closes number to itself other than itself within tolerance, if exists
  
  # make x distinct
  query <- unique({{x}})
  
  # make tibble
  matches <- tibble(
    ys = {{y}},
    match = near(query, ys, {{tol}})) # tell me if i element in col is near x value
  
  
  # return match value 
  closest_y <- matches %>%
    filter(match == TRUE) %>% # keep only vals within tolerance
    filter(ys != query) %>% # value should not be itself
    distinct(ys)
  
  return_vector <- as.vector(closest_y$ys)
  
  
  # if length of return rector is 0, replace with NA
  if (length(return_vector) == 0) {
    return_vector <- NA_integer_
  }
  
  return(return_vector)
  
}
 

pg34data <- pdftools::pdf_data(psic09_path)[[34]]

pg34 <- read_pdf2(
  
  pdf_path = psic09_path,
  page_min = 34,
  page_max = 34,
  varnames = c("class", "subclass", "psic1994", "isic4", "acic"),
  ymin = 90,
  xlabel = c(155, 420),
  xmin = c(91, 131, 415, 446, 501),
  xmax = c(130, 175, 445, 500, 9999),
  header = TRUE
) %>%
  arrange(y)

View(pg34)

## this works
pg34 %>%
  group_by(y) %>%
  mutate(page_grp = cur_group_id(),
         page = 34,
         n_in_row = n(),
         nearest_y = nearest_neighbor(y, pg34[["y"]], tol = 12)) %>%
  arrange(page_grp, nearest_y) %>%
  ungroup() %>%
  mutate(y2 = case_when(is.na(nearest_y) ~ y,
                        nearest_y >  y  ~ nearest_y,
                        nearest_y <  y  ~ y)) %>%
  group_by(y2) %>%
  mutate(page_grp2 = cur_group_id(),
         n_in_row2 = n()) %>%
  arrange(page_grp2) %>%
  pivot_wider(names_from = "varname",
               values_from = "text",
               id_cols = all_of(c("y2", "page_grp2", "page"))) %>%
  View()



pg34data %>%
  filter(y > 600 & y < 700) %>% 
  View()   

# start here.
pg34 <- read_pdf(
  
  pdf_path = psic09_path,
  page_min = 34,
  page_max = 34,
  varnames = c("class", "subclass", "psic1994", "isic4", "acic"),
  ymin = 90,
  xlabel = c(155, 420),
  xmin = c(91, 131, 415, 446, 501),
  xmax = c(130, 175, 445, 500, 9999),
  header = TRUE,
  match_tol = 3
) %>%
  arrange(y)


iris %>% 
  group_by(Species) %>%
  mutate(test = paste0(Species, max(.data[[Petal.Length]])))









tib <- tribble(
  ~a, ~b,
  1, 10, 
  2, 13,
  47, 17,
  109, NA,
  7, 18
)

# this function adds a column to a data frame
nearest_neighbor <- function(data, # usually passed from %>%
                             col, # column to iterate over
                             match_col,
                            match_tol=5) {
  
  tib <- data %>%
    mutate(
      match = purrr::map_dbl(.x = {{col}}, function(x, ...) {
        
        
        # col = match_col 
        # element = x
        # make tibble of matches
        matches <- tibble(
          ys = match_col,
          match = near(x, match_col, match_tol))
        
        # return match value 
        closest_y <- matches %>%
          filter(match == TRUE) %>% # keep only vals within tolerance
          filter(ys != x) %>% # value should not be itself
          distinct(ys)
        
        return_vector <- as.vector(closest_y$ys)
        
        
        # if length of return rector is 0, replace with NA
        if (length(return_vector) == 0) {
          return_vector <- NA_integer_
        }
        
        return(return_vector)
        
        
        
        
      })
    )
  
  return(tib)

  
}

pg34 %>%
  nearest_neighbor(., y, y, 5)
# how to subset the column name of the dataframe??


pg34 %>%
  group_by(y) %>%
  mutate(page_grp = cur_group_id(),
         page = 34,
         n_in_row = n(),
         nearest_y = purrr::map_dbl(.x = y, function(x, ...) {
           
           x + 2
         })
         
         ) 
  



nn <- function(ref_col, match_tol=3, ...) {
  
  
  purrr::map_dbl(.x = {{ref_col}}, function(x, ...) {
    

    # # make tibble of matches
    matches <- tibble(
      ys = {{ref_col}},
      match = near(x, {{ref_col}}, {{match_tol}}))

    # return closest match value
    closest_y <- matches %>%
      filter(match == TRUE) %>% # keep only vals within tolerance
      filter(ys != x) %>% # value should not be itself
      distinct(ys) %>%
      mutate(dif = abs(x - ys)) %>%
      arrange(dif)
    
    return_val <- as.vector(closest_y$ys)[1] # take number where dif is smallest
    
    
    # if length of return rector is 0, replace with NA
    if (length(return_val) == 0) {
      return_val <- NA_integer_
    }
    
    return(return_val)
    
    
    
    
  })

  
  
}

nn(tib$a)

tib %>%
  mutate(test = nn(a, 10))

