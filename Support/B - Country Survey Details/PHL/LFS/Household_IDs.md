Household IDs: Philippines GLD
================

-   [Overview](#overview)
-   [Table of Missing HHID variables in data](#table-of-missing-hhid-variables-in-data)
-   [Years 1997 - 2007: Constructing a unique Household ID](#years-1997---2007-constructing-a-unique-household-id)
    -   [Note on 2003, 2004, 2006, and 2007](#note-on-2003-2004-2006-and-2007)
-   [Notes on 2012](#notes-on-2012)
-   [Notes on 2017](#notes-on-2017)

This document describes how household IDs are handled across all survey years.

## Overview

As with all GLD surveys, the data should be uniquely identifiable with the Household ID variable `hhid` and the Individual ID variable `pid`. The `pid` is only uniquely identifiable within the household – not globally in the survey.

The Philippine LFS survey provides a unique household identifier/variable in rounds starting in 2004. For these years, that variable is used to contsruct `hhid`. For years prior to 2008, there is no given household identifier so one must be constructed.

## Table of Missing HHID variables in data

For all years prior to 2008, at least one round lacks an as-is household ID variable. Manual HHID construction will occur for these rounds with missing HHID variables.

| Year | January                  | April                    | July                     | October                  |
|------|--------------------------|--------------------------|--------------------------|--------------------------|
| 1997 |                          |                          |                          |                          |
| 1998 |                          |                          |                          |                          |
| 1999 |                          |                          |                          |                          |
| 2000 |                          |                          |                          |                          |
| 2001 |                          |                          |                          |                          |
| 2002 |                          |                          |                          |                          |
| 2003 |                          |                          |                          |                          |
| 2004 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |                          |
| 2005 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2006 | :white\_check\_mark:     | :white\_check\_mark:     |                          |                          |
| 2007 |                          | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2008 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2009 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2010 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2011 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2012 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2013 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2014 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2015 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2016 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2017 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |
| 2018 | **:white\_check\_mark:** | **:white\_check\_mark:** | **:white\_check\_mark:** | **:white\_check\_mark:** |
| 2019 | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     | :white\_check\_mark:     |

## Years 1997 - 2007: Constructing a unique Household ID

The constructed Household ID must satisfy at least two primary conditions:

1.  The household groupings it produces should be at least descriptively reflected in the PSA publications

2.  The Household ID, along with the given line number variable, should uniquely identify all observations, minus obvious duplicates.

The following table gives a list of the variable combinations used to determine unique household IDs in each year and the resulting number of households that combination generates if/once duplicates are removed.

### Note on 2003, 2004, 2006, and 2007

The first two rounds of 2003 differ from the final two: while the first two rounds’ household ID can be identified similarly to those in previous years, the final two rounds of 2003 do not have the typical geographic variables and need to use a different determining set. The case is similar for 2004: the final round does not have a single, unique household ID variable and so one must be constructed for the entire four-round year. Years 2006 and 2007 present similar situations.

## Notes on 2012

2012 does not have a valid, non-missing line number variable that is present on all observations across all years, so in this year I will generate a “line number” variable myself by using the row number within each household grouping.

## Notes on 2017

Even though 2017 does have a household ID variable provided in all 4 rounds, this varible does not uniquely identify observations along with the line number and round variables. Instead it produces many duplicates, so a HHID will be constructed.

| Year                 | Household ID Combination                                            | Manage Duplicates          | Unique Household Number |
|----------------------|---------------------------------------------------------------------|----------------------------|-------------------------|
| 1997                 | regn prov hcn                                                       |                            |                         |
| 1998                 | regn prov hcn                                                       |                            |                         |
| 1999                 | regn prov hcn                                                       |                            |                         |
| 2000                 | regn prov hcn                                                       |                            |                         |
| 2001                 | regn prov hcn                                                       |                            |                         |
| 2002                 | regn prov hcn                                                       |                            |                         |
| 2003 Jan+Apr         | regn prov hcn                                                       |                            |                         |
| 2003 Jul+Oct         | creg stratum psu ea\_unique shsn hcn                                |                            |                         |
| 2004 Jan, Apr, Jul   | *unique hhid provided*                                              |                            |                         |
| 2004 Oct             | creg, prov, stratum, psu, ea\_unique, shsn, hcn                     |                            |                         |
| 2005                 | *unique hhid provided but named differently*                        |                            |                         |
| 2006 Jan + Apr       | *unique hhid provided*                                              |                            |                         |
| 2006 Jul + Oct       | creg, prov, stratum, psu, ea\_unique, shsn, hcn                     | 1 household (October only) |                         |
| 2007 Jan             | w\_regn, w\_prv, w\_ea, w\_shsn, lstr, eaunique\_psu, w\_hcn \| 4 H | ouseholds \|               |                         |
| 2007 Apr + Jul + Oct | *unique hhid provided* \|                                           |                            |                         |
| 2017 Apr             | \| lreg, l1prrcd, l1mun, l1ea, lhusn, l1bgy, lhsn, lpsu \|          |                            |                         |
| 2017 Jan+Jul+Oct     | unique HHID provided, but not unique in January \| 1 houshol        | d (Jan only)               |                         |
