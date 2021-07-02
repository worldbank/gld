# Household IDs: Philippines I2D2
This document describes how household IDs are handled across all survey years.

## Overview
As with all I2D2 surveys, the data should be uniquely identifiable with the Household ID variable `hhid` and the Individual ID variable `pid`. The `pid` is only uniquely identifiable within the household -- not globally in the survey.

The Philippine LFS survey provides a unique household identifier/variable in rounds starting in 2004. For these years, that variable is used to contsruct `hhid`. For years prior to 2004, there is no given household identifier so one must be constructed.

## Years 1997 - 2003: Constructing a unique Household ID
The constructed Household ID must satisfy at least two primary conditions:
1. The household groupings it produces should be at least descriptively reflected in the PSA publications
2. the Household ID, along with the given line number variable, should uniquely identify all observations, minus obvious duplicates.

The following table gives a list of the variable combinations used to determine unqiue household IDs in each year and the resulting number of households that combination generates if/once duplicates are removed.

### Note on 2003
The first two rounds of 2003 differ from the final two: while the first two rounds' household ID can be identified similarly to those in previous years, the final two rounds of 2003 do not have the typical geographic variables and need to use a different determining set.


| Year       |   Household ID Combination | Unique Household Number |
|---------|-----------------------|----------------------|
| 1997  |    regn   hcn  |	 |
| 1998 |   regn   hcn | |
| 1999 | regn   hcn	 |  |
| 2000 | regn   hcn |  |
| 2001 | regn hcn |  |
| 2002 | regn prov hcn | |
| 2003 Jan+Apr | regn prov hcn  |  |
| 2003 Jul+Oct | creg stratum psu ea_unique shsn hcn | |
