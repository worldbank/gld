cap program drop primus_xml_gld

program define primus_xml_gld, rclass
    version 14.0
    syntax [anything], xmlout(string) country(string) year(string) ///
        surveyid(string) filename(string) [byvar(varname) weightlist(varname)]

    ***************************** Setup ***************************
    local weightlist = cond("`weightlist'" == "", "weight", "`weightlist'")

    preserve
    tempfile data0
    save `data0', replace


    ************************* Generate Excel datetime *************************
    gen double __dt = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    gen double __excel_dt = (__dt / 1000 / 60 / 60 / 24) + 25569
    scalar excel_datetime = __excel_dt[1]

    ************************* Begin Writing XML *************************
    tempname outfile
    file open `outfile' using "`xmlout'", write text replace
    file write `outfile' "<PRIMUS_ANALYSIS>" _n
    file write `outfile' _col(2) "<Request>" _n
    file write `outfile' _col(4) "<RequestKey><![CDATA[]]></RequestKey>" _n
    file write `outfile' _col(4) "<employment>lstatus</employment>" _n
    file write `outfile' _col(4) "<weight>`weightlist'</weight>" _n
    file write `outfile' _col(4) "<By></By>" _n
    file write `outfile' _col(4) "<N_By_Group>1</N_By_Group>" _n
    file write `outfile' _col(4) "<nParamSets>1</nParamSets>" _n
    file write `outfile' _col(4) "<![CDATA[" _n
    file write `outfile' _col(4) "APP_ID;Stata" _n
    file write `outfile' _col(4) "DATETIME;`=scalar(excel_datetime)'" _n
    file write `outfile' _col(4) "FILE_SIZE;" _n
    file write `outfile' _col(4) "IS_INTERPOLATED;FALSE" _n
    file write `outfile' _col(4) "USE_MICRODATA;TRUE" _n
    file write `outfile' _col(4) "COUNTRY_CODE;`country'" _n
    file write `outfile' _col(4) "COUNTRY_NAME;" _n
    file write `outfile' _col(4) "SURVEY_ID;`surveyid'" _n
    file write `outfile' _col(4) "FILENAME;`filename'" _n
    file write `outfile' _col(4) "REGION_CODE;REG" _n
    file write `outfile' _col(4) "DATA_COVERAGE;" _n
    file write `outfile' _col(4) "DATA_TYPE;" _n
    file write `outfile' _col(4) "DATA_YEAR;`year'" _n
    file write `outfile' _col(4) "]]>" _n
    file write `outfile' _col(2) "</Request>" _n

    file write `outfile' _col(2) "<Result>" _n
    file write `outfile' _col(4) `"<Employment var="lstatus" weight="`weightlist'">"' _n

    use `data0', clear
    gen count = 1

    quietly {
        count
        local nRecs = r(N)

        su count [aw=`weightlist']
        local TotalPop = r(sum_w)

        su count [aw=`weightlist'] if lstatus == 1
        local Employed = r(sum_w)

        su count [aw=`weightlist'] if lstatus == 2
        local Unemployed = r(sum_w)

        local NLF = `TotalPop' - (`Employed' + `Unemployed')

        local EmployedRate = 100 * (`Employed' / `TotalPop')
        local UnemployedRate = 100 * (`Unemployed' / `TotalPop')
        local NLFRate = 100 * (`NLF' / `TotalPop')
    }

    file write `outfile' _col(4) "<ByGroup byCondition='none'>" _n
    file write `outfile' _col(6) "<DATASUMMARY>" _n
    file write `outfile' _col(8) "<![CDATA[" _n
    file write `outfile' _col(8) "nRecs;`nRecs'" _n
    file write `outfile' _col(8) "TotalPopulation;`=round(`TotalPop')'" _n
    file write `outfile' _col(8) "Employed;`=round(`Employed')'" _n
    file write `outfile' _col(8) "Unemployed;`=round(`Unemployed')'" _n
    file write `outfile' _col(8) "NLF;`=round(`NLF')'" _n
    file write `outfile' _col(8) "]]>" _n
    file write `outfile' _col(6) "</DATASUMMARY>" _n

    file write `outfile' _col(6) "<CALCULATION>" _n
    file write `outfile' _col(8) "<![CDATA[" _n
    file write `outfile' _col(8) "METHOD;Percent15+" _n
    file write `outfile' _col(8) "Employed;`=string(`EmployedRate', "%9.2f")'%" _n
    file write `outfile' _col(8) "Unemployed;`=string(`UnemployedRate', "%9.2f")'%" _n
    file write `outfile' _col(8) "NLF;`=string(`NLFRate', "%9.2f")'%" _n
    file write `outfile' _col(8) "]]>" _n
    file write `outfile' _col(6) "</CALCULATION>" _n
    file write `outfile' _col(4) "</ByGroup>" _n

    file write `outfile' _col(4) "</Employment>" _n
    file write `outfile' _col(2) "</Result>" _n

    file write `outfile' _col(2) "<LOG_DETAIL>" _n
    file write `outfile' _col(8) "<![CDATA[" _n
    file write `outfile' _col(4) "-------------------------------------------------------------------------------------------------------" _n
    file write `outfile' _col(4) "Nothing to note" _n
    file write `outfile' _col(4) "-------------------------------------------------------------------------------------------------------" _n
    file write `outfile' _col(4) "]]>" _n
    file write `outfile' _col(2) "</LOG_DETAIL>" _n
    file write `outfile' "</PRIMUS_ANALYSIS>" _n

    file close `outfile'
    restore
end
