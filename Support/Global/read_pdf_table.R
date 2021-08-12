# read_pdf.R




#### General Function #####



read_pdf <- function(page, pdfPath,
                     
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     x_label = c(155, 420),
                     xmin = c(91, 131, 415, 446, 501),
                     xmax = c(130, 175, 445, 500, 9999)
                     ) {
  
  
  # define sub-function that extracts column info from partially-processed data
  col_info <- function(data_in, xmin, xmax, varname) {
    
    tib <- data_in %>%
      filter(x >= xmin & x < xmax) %>%
      select(text, y) %>%
      mutate(varname = as.character(varname))
    
    return(tib)
  }
  
  
  # subset data loaded by pdftools
  data <- psic09[[page]] # make this the second argument
  
  data_nolabs <- data %>%
    filter(x < 155 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  data_tib <- data_nolabs %>%
    filter(y >= 90) %>% # remove page titles, if no data, no obs.
    select(x, y, text) %>%
    
    
    
    # columns: return sub-function individually and bind
    el_class <- col_info(data_tib, xmin = 91, xmax = 130, varname = "class")
  el_subclass <- col_info(data_tib, xmin = 131, xmax = 175, varname = "subclass")
  
  el_psic1994 <- col_info(data_tib, xmin = 415, xmax = 445, varname = "psic1994")
  el_isic4 <- col_info(data_tib, xmin = 446, xmax = 500, varname = "isic4")
  el_acic <- col_info(data_tib, xmin = 501, xmax = 9999, varname = "acic")
  
  
  tib <- bind_rows(el_class, el_subclass, el_psic1994, el_isic4, el_acic) %>%
    group_by(y) %>%
    mutate(page_grp = cur_group_id(),
           page = page) %>%
    pivot_wider(names_from = "varname",
                values_from= "text")
  
  
  
  return(tib)
  
  
  
  
}

# function call ----
## test on industry first 
psic09 <- pdftools::pdf_data(psic_path)

raw <- lapply(22:316, read_pdf) # returns list vector same length as x after apply function
raw <- do.call(rbind, raw)



# single page call
read_isic_pdf(76)