capture program drop gld_isco_check

program define gld_isco_check

    syntax [, occupation(varname) show]

    tempvar count
    qui gen `count' = 1

    * Default occupation variable
    if "`occupation'" == "" local occupation occup_isco

    preserve
        * Collapse to unique occupation codes in the current data
        qui collapse (sum) `count', by(`occupation')
        qui drop if missing(`occupation')
        local total_occupations = _N

        tempfile startingdata
        qui save `startingdata'
    restore

    preserve
        * Load ISCO helper list from GLD repo
        qui import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Single%20survey%20checks/Helper_programs_1.5/isco_codes.txt", delimiter(comma) varnames(1) stringcols(_all) clear
        qui levelsof version, local(ver)

        tempfile iscolist
        qui save `iscolist'
    restore

    preserve
        foreach v of local ver {
            use `iscolist', clear
            qui keep if version == "`v'"
            rename code `occupation'

            qui merge 1:1 `occupation' using `startingdata'
            qui count if _merge == 3
            local matches = r(N)

            local percent_match = (100 * `matches') / `total_occupations'

            di "Version `v' matches: `matches' ==> " %8.2f `percent_match' "% of total occupation codes in data"

            if "`show'" != "" & `percent_match' != 100 {
                di as error "These are the codes not in `v'"
                list `occupation' if _merge == 2
            }
        }
    restore

end
