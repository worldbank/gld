# read_pdf.R


#### General Function #####

read_pdf <- function(pdf_path, page_min, page_max, 
                     
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     xlabel = c(155, 420),
                     xmin = c(91, 131, 415, 446, 501),
                     xmax = c(130, 175, 445, 500, 9999)
                     
                     ) {
 
  
  
  
   
  # define 1st sub-function to import the table
  import_table_pdf <- function( page, ... ) {
    
    
    # define 2nd sub-function that extracts column info from partially-processed data
    col_info <- function(data_in, x_min, x_max, var_name) {
      
      tib <- data_in %>%
        filter(x >= x_min & x < x_max) %>%
        select(text, y) %>%
        mutate(varname = as.character(var_name))
      
      return(tib)
    }
    
    
    
    ##### Data work #####
   
    
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
      filter(y >= ymin) %>% # remove page titles, if no data, no obs.
      select(x, y, text)
    
    
    
    # columns: return sub-function individually and bind
    el_1 <- col_info(data_tib, x_min = xmin[1], x_max = xmax[1], var_name = as.character(varnames[1]))
    el_2 <- col_info(data_tib, x_min = xmin[2], x_max = xmax[2], var_name = as.character(varnames[2]))
    
    el_3 <- col_info(data_tib, x_min = xmin[3], x_max = xmax[3], var_name = as.character(varnames[3]))
    el_4 <- col_info(data_tib, x_min = xmin[4], x_max = xmax[4], var_name = as.character(varnames[4]))
    el_5 <- col_info(data_tib, x_min = xmin[5], x_max = xmax[5], var_name = as.character(varnames[5]))
    
    
    
    table <- bind_rows(el_1, el_2, el_3, el_4, el_5) %>%
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
 
#  read_pdf(
#             pdf_path = psic_path,
#             page_min = 22,
#             page_max = 316,
#             varnames = c("class", "subclass", "psic1994", "isic4", "acic")
#             )
     