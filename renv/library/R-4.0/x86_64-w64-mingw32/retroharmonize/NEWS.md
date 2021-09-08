# retroharmoinze 0.1.17
* Release candidate to CRAN

# retroharmoinze 0.1.16
* Package moved to [rOpenGov](https://github.com/rOpenGov/retroharmonize/).
* [Arab Barometer](https://retroharmonize.dataobservatory.eu/articles/arabbarometer.html) tutorial vignette.
* Transition to tidyverse 1.0+ with using the rlang `.data` pronoun, etc.
* Bug fix in `harmonize_waves()`: Date types are now correctly harmonized.
* We started building an experimental APIs data is running regions regularly and improving known statistical data sources.  See: [Digital Music Observatory](https://music.dataobservatory.eu/), [Green Deal Data Observatory](https://greendeal.dataobservatory.eu/), [Economy Data Observatory](https://economy.dataobservatory.eu/).

# retroharmoinze 0.1.15
* Documentation improvements.
* A new function, `harmonize_var_names()`, helps to systematically rename variables in a list of surveys. Conventional names to keep are returned by `suggest_permanent_names()`, and the helper function `suggest_var_names()` provides a simple wrapper around `var_label_normalize()` and `suggest_permanent_names()`.
* A new function, `subset_waves()`, helps to subset a wave of surveys.
* With the help of [goodpractice](https://github.com/mangothecat/goodpractice), some coding good practices are introduced.

# retroharmoinze 0.1.14
* `harmonize_values()` now accepts perl-like regex.

# retroharmonize 0.1.13
* In the examples that use file operations, dontrun{} replaced by donttest{}. 
* This is the first released version on CRAN.

# retroharmonize 0.1.12
retroharmonize 0.1.6-0.1.12 are making the package ready for CRAN release.

# retroharmonize 0.1.5
* retroharmonize 0.1.1-0.1.5 are not intended for release, they contain numerous development stages of a new package.

# retroharmonize 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Class definition and description.













