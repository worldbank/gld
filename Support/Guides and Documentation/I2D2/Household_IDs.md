# Household IDs: Philippines I2D2

This document describes how household IDs are handled across all survey years.

## Overview

As with all I2D2 surveys, the data should be uniquely identifiable with the Household ID variable `hhid` and the Individual ID variable `pid`. The `pid` is only uniquely identifiable within the household -- not globally in the survey.

The Philippine LFS survey provides a unique household identifier/variable in rounds starting in 2004. For these years, that variable is used to contsruct `hhid`. For years prior to 2008, there is no given household identifier so one must be constructed.

## Table of Missing HHID variables in data

For all years prior to 2008, at least one round lacks an as-is household ID variable. Manual HHID construction will occur for these rounds with missing HHID variables.

| Year | January | April | July  | October |
|------|---------|-------|-------|---------|
| 1997 |         |       |       |         |
| 1998 |         |       |       |         |
| 1999 |         |       |       |         |
| 2000 |         |       |       |         |
| 2001 |         |       |       |         |
| 2002 |         |       |       |         |
| 2003 |         |       |       |         |
| 2004 | ✅       | ✅     | ✅     |         |
| 2005 | ✅       | ✅     | ✅     | ✅       |
| 2006 | ✅       | ✅     |       |         |
| 2007 |         | ✅     | ✅     | ✅       |
| 2008 | ✅       | ✅     | ✅     | ✅       |
| 2009 | ✅       | ✅     | ✅     | ✅       |
| 2010 | ✅       | ✅     | ✅     | ✅       |
| 2011 | ✅       | ✅     | ✅     | ✅       |
| 2012 | ✅       | ✅     | ✅     | ✅       |
| 2013 | ✅       | ✅     | ✅     | ✅       |
| 2014 | ✅       | ✅     | ✅     | ✅       |
| 2015 | ✅       | ✅     | ✅     | ✅       |
| 2016 | ✅       | ✅     | ✅     | ✅       |
| 2017 | ✅       | ✅     | ✅     | ✅       |
| 2018 | **✅**   | **✅** | **✅** | **✅**   |
| 2019 | ✅       | ✅     | ✅     | ✅       |

## Years 1997 - 2007: Constructing a unique Household ID

The constructed Household ID must satisfy at least two primary conditions: 1. The household groupings it produces should be at least descriptively reflected in the PSA publications 2. the Household ID, along with the given line number variable, should uniquely identify all observations, minus obvious duplicates.

The following table gives a list of the variable combinations used to determine unique household IDs in each year and the resulting number of households that combination generates if/once duplicates are removed.

### Note on 2003, 2004, 2006, and 2007

The first two rounds of 2003 differ from the final two: while the first two rounds' household ID can be identified similarly to those in previous years, the final two rounds of 2003 do not have the typical geographic variables and need to use a different determining set. The case is similar for 2004: the final round does not have a single, unique household ID variable and so one must be constructed for the entire four-round year. Years 2006 and 2007 present similar situations.

| Year               | Household ID Combination                                   | Manage Duplicates          | Unique Household Number |
|--------------------|------------------------------------------------------------|----------------------------|-------------------------|
| 1997               | regn prov hcn                                              |                            |                         |
| 1998               | regn prov hcn                                              |                            |                         |
| 1999               | regn prov hcn                                              |                            |                         |
| 2000               | regn prov hcn                                              |                            |                         |
| 2001               | regn prov hcn                                              |                            |                         |
| 2002               | regn prov hcn                                              |                            |                         |
| 2003 Jan+Apr       | regn prov hcn                                              |                            |                         |
| 2003 Jul+Oct       | creg stratum psu ea_unique shsn hcn                        |                            |                         |
| 2004 Jan, Apr, Jul | *unique hhid provided*                                     |                            |                         |
| 2004 Oct           | creg, prov, stratum, psu, ea_unique, shsn, hcn             |                            |                         |
| 2005               | *unique hhid provided but named differently*               |                            |                         |
| 2006 Jan + Apr     | *unique hhid provided*                                     |                            |                         |
| 2006 Jul + Oct     | creg, prov, stratum, psu, ea_unique, shsn, hcn             | 1 household (October only) |                         |
| 2007 Jan           | w_regn, w_prv, w_ea, w_shsn, lestrata, eaunique_psu, w_hcn | 4 Households               |                         |

## 
