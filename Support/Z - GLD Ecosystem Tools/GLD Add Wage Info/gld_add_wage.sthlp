{smcl}
{hline}
{* 8Jul2020 }{...}
{cmd:help gld_add_wage}{right:dialog:  {bf:{dialog gld_add_wage}}}
{right: {bf:version 1.0}}
{hline}

{title:Title}

{p2colset 9 24 22 2}{...}
{p2col :{hi:gld_add_wage}{hline 2}}GLD function to add wage information.{p_end}
{p2colreset}{...}

{title:Description}
{pstd}

{p 4 4 2}{cmd:gld_add_wage} Construct hourly and/or monthly wage for information based on

- wage_no_compen(_year) : Pre tax earnings without employer contributions
- unitwage(_year)       : Time period the wage refers to)
- whours(_year)         : Number of hours works in a week)
- empstat(_year)        : Employment status
- lstatus(_year)        : Labour status

over the 7 day or 12 month recall periods. It will also give the information in PPP values (PA.NUS.PPP) if requested.


{title:Syntax}

{p 6 16 2}
{cmd:gld_add_wage}{cmd:,} {it:{help gld_add_wage##options:Parameters}} [{it:{help gld_add_wage##options:Options}}]


{synoptset 27 tabbed}{...}
{synopthdr:Parameters}
{synoptline}
{synopt :{opt WORKer}(String)}Define whether interested in wage worker (enter "w" or "waged") or all workers (enter "a" or "all"){p_end}
{synopt :{opt TIME}(String)}Define the recall period, either 7 day (enter "w" or "week"), 12 month (enter "y" or "year"), or both (enter "b" or "both"){p_end}
{synopt :{opt THREshold}(Numeric)}Define the threshold of group members with wage info sufficient to calculate information - default is 75%{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt :{opt PPP}}Determine whether to add variables with PPP info{p_end}

