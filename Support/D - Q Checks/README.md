# Quality checks

For the purpose of checking the harmonization of GLD data, we use to processes, each stored here in a separate folder.

The first are the single survey checks. These ensure each survey, on its own follows the rules of the GLD data dictionary and its results are consistent both internally (e.g., the relationship between skill and wages looks sound) and externally (e.g., comparing labour force participation with ILO data).

The second are the survey series checks. These look at a whole set of surveys over time. They should commonly only be used once a set of surveys has been completed and all have individually passed the single survey checks. They evaluate graphically a series of key indicators to ensure the time series is coherent over time. For example, it may be that a single year - consistent in itself - has a different definition of education categories, causing the `educat#` variables to be off for that year. This can be easily detected with these checks.
