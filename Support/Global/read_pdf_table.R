# read_pdf.R


#### General Function #####

read_pdf <- function(pdf_path, page_min, page_max, 
                     
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
      filter(!grepl("^p;", text)) %>% 
      group_by(y) %>%
      mutate(page_grp = cur_group_id(),
             page = page) %>%
      pivot_wider(names_from = "varname",
                  values_from= "text")

    
    
    return(table)

  }
  
  
  ## Import the PDF with pdftools 
  pdf <- pdftools::pdf_data(pdf_path) 
  
  
  ## perform the function call with purrr 
  raw <- pmap(list(page_min:page_max), import_table_pdf)
  raw <- do.call(rbind, raw)
  
  
  return(raw)
  
}
 
 # read_pdf(
 #            pdf_path = psic_path,
 #            page_min = 22,
 #            page_max = 30,
 #            varnames = c("class", "subclass", "psic1994", "isic4", "acic")
 #            )
     