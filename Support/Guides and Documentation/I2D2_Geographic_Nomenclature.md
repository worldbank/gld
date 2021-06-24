# I2D2 Geographic Variable Nomenclature

## Introduction
The I2D2 dataset contains four geographic or adminstrative level variables, which draw from existing data in the country or economy of analysis: `reg01`, `reg02`, `reg03`, `reg04`.

## Schema

The naming nomenclature is as follows:
`reg01`: is the preferred geographic area of analysis. This could refer to an ambiguous, large conceptual area (such as the "northeast") or a granular area such as the urban/rural divide within a third level disaggregation.
`reg02`: the first level of geographic administrative disaggregation. Typically the largest unit in area, on average.
`reg03`: the second level of geographic administrative disaggregation.
`reg04`: the third level of geographic administrative disaggregation. Typically the smallest unit in area, on average.

Since `reg01` is flexible, `reg01` can refer to the same geographic variable as another "reg" variable, and often will. 

It is worth noting that not all countries or economies will have all four geographic variables given the administrative differences in each place. When this is the case, the values are simply set to missing, or `.` in Stata format.
