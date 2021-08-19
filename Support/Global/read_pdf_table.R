#' Read information from a table in PDF format
#' 
#' @param pdf_path The file path to the pdf to read
#' @param page_min The starting page number (inclusive) to begin reading the file.
#' @param page_max The ending page number (inclusive) to end reading the file.
#' @param header A boolean statement indicating if the document always has a constant page header on all pages 
#' @param varnames A list of variable names of the output columns
#' @param ymin The minimum y coordinate on the page where the function will read information
#' @param xlabel a 2-element list that indicates start and ending x-coordinates of omitted columns
#' @param xmin a list of x-coordinate column minimums. Same length as varnames.
#' @param xmax a list of x-coordinate column maximums. Same length as varnames.
#' @param numlist an optional vector of omitted numbers to filter. 
#' @param match_tol the nearest-neighbor y match tolerance for misaligned rows

read_pdf <- function(pdf_path, page_min, page_max, 
                     
                     header = TRUE,
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     xlabel = c(155, 420),
                     xmin = c(91, 131, 415, 446, 501),
                     xmax = c(130, 175, 445, 500, 9999),
                     numlist = NULL,
                     match_tol = 2
                     
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
    
    
    
    # define 3rd sub-function that matches close y-value rows
    #     # finds closes number to itself other than itself within tolerance, if exists
    nearest_neighbor <- function(x, # input row's y (single value)
                                 y, # whole y column (whole col)
                                 ...) {
      
      
      
      # make x distinct
      query <- unique({{x}})
      
      # make tibble
      matches <- tibble(
        ys = {{y}},
        match = near(query, ys, {{match_tol}})) # tell me if i element in col is near x value
      
      
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
    
    table %<>% 
      group_by(y) %>%
      mutate(page_grp = cur_group_id(),
             page = page,
             n_in_row = n(),
             nearest_y = nearest_neighbor(y, table[["y"]], tol = 12)) %>% # data pronoun
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
                  id_cols = all_of(c("y2", "page_grp2", "page")))

    
    
    return(table)

  }
  
  
  ## Import the PDF with pdftools 
  pdf <- pdftools::pdf_data(pdf_path) 
  
  
  ## perform the function call with purrr 
  raw <- pmap(list(page_min:page_max), import_table_pdf)
  raw <- do.call(rbind, raw)
  
  return(raw)
  
}
 