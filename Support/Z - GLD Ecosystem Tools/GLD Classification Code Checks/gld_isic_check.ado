capture program drop gld_isic_check

program define gld_isic_check

    syntax [, industry(varname) show]

    tempvar count
    qui gen `count' = 1

    * Default industry variable
    if "`industry'" == "" local industry industrycat_isic

    preserve
        * Collapse to unique industry codes in the current data
        qui collapse (sum) `count', by(`industry')
        qui drop if missing(`industry')
        local total_industries = _N

        tempfile startingdata
        qui save `startingdata'
    restore

    preserve
        * Load ISIC helper list from GLD repo
        qui import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Single%20survey%20checks/Helper_programs_1.5/isic_codes.txt", delimiter(comma) varnames(1) stringcols(_all) clear
        qui levelsof version, local(ver)

        tempfile isiclist
        qui save `isiclist'
    restore

    preserve
        foreach v of local ver {
            use `isiclist', clear
            qui keep if version == "`v'"
            rename code `industry'

            qui merge 1:1 `industry' using `startingdata'
            qui count if _merge == 3
            local matches = r(N)

            local percent_match = (100 * `matches') / `total_industries'

            di "Version `v' matches: `matches' ==> " %8.2f `percent_match' "% of total industry codes in data"

            if "`show'" != "" & `percent_match' != 100 {
                di as error "These are the codes not in `v'"
                list `industry' if _merge == 2
            }
        }
    restore

end
