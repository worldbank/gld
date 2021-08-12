# read_pdf.R




#### General Function #####

read_pdf <- function(page,
                     
                     varnames = c("var1", "var2", "var3", "var4", "var5"),
                     ymin = 90,
                     xlabel = c(155, 420),
                     xmin = c(91, 131, 415, 446, 501),
                     xmax = c(130, 175, 445, 500, 9999)
                     
                        ) {
  
  
  # define sub-function that extracts column info from partially-processed data
  col_info <- function(data_in, x_min, x_max, var_name) {
    
    tib <- data_in %>%
      filter(x >= x_min & x < x_max) %>%
      select(text, y) %>%
      mutate(varname = as.character(var_name))
    
    return(tib)
  }
  
  
  # note: we could read the data directly from pdftools each time but that's computationally
  # expensive. It's better to read in the whole pdf as one object outside the function and 
  # call the object from outside the function -- until I can figure out a more elegant way 
  # to do this in the function itself.
  
  # subset data loaded by pdftools
  data <- pdf_page_list[[page]] # make this the second argument
  
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
  
  

  tib <- bind_rows(el_1, el_2, el_3, el_4, el_5) %>%
    group_by(y) %>%
    mutate(page_grp = cur_group_id(),
           page = page) %>%
    pivot_wider(names_from = "varname",
                values_from= "text")

  
  
  return(tib)
  
  
}

# function call ----

# single page call
# read_pdf(page = 47,
#          varnames = c("class", "subclass", "psic1994", "isic4", "acic")
#          )


## sample use flow
## 1. load the pdf file as a list object using pdftools. 
##     note, you must load the pdf list as this named object since 
##     the function depends on the object from the global envrionment (until
##     I can think of a better way to do this)

#pdf_page_list <- pdftools::pdf_data(psic_path) 

## 2. Test the function on a single page with some parameters. You will need to define  
##    variable names, the xmin/xmax for each column, and the y cutoff (or where the 
##    table header ends on the top of each page.) You will also need to define the 
##    block of text in the middle of the table where the labels are stored. Test this with 

#read_pdf(47) # or another page number


## 3. Perform the Function Call for all pages. Careful. if there's an error on any single
## page the function won't run. Warnings are ok.

#raw <- lapply(22:316, read_pdf) # returns list vector same length as x after apply function
#raw <- do.call(rbind, raw)

## 4. Clean the output data.
##  The output is designed to be not clean at all becuase it will vary. Things to be 
##  mindful of are stray punctuation marks or alpha characters that you will want to
##  filter out, duplicates, or empty/meaningless rows. You may also want to add or remove
##  variables accordingly.



