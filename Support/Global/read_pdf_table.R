# read_pdf.R




#### General Function #####



read_pdf <- function(page, pdfPath,
                     
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     xlabel = c(155, 420),
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
    filter(x < xlabel[1] | x > xlabel[2]) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  data_tib <- data_nolabs %>%
    filter(y >= ymin) %>% # remove page titles, if no data, no obs.
    select(x, y, text) %>%
    
    
    
    # columns: return sub-function individually and bind
    el_1 <- col_info(data_tib, xmin = xmin[1], xmax = xmax[1], varname = as.character(varnames[1]))
  el_2 <- col_info(data_tib, xmin = xmin[2], xmax = xmax[2], varname = as.character(varnames[2]))
  
  el_3 <- col_info(data_tib, xmin = xmin[3], xmax = xmax[3], varname = as.character(varnames[3]))
  el_4 <- col_info(data_tib, xmin = xmin[4], xmax = xmax[4], varname = as.character(varnames[4]))
  el_5 <- col_info(data_tib, xmin = xmin[5], xmax = xmax[5], varname = as.character(varnames[5]))
  
  
  tib <- bind_rows(el_1, el_2, el_3, el_4, el_5) %>%
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