renv: A Quick Guide
================

-   [What is `renv`?](#what-is-renv)
-   [How We Use `renv`](#how-we-use-renv)
    -   [Using `renv` for the first
        time](#using-renv-for-the-first-time)
    -   [Using `renv` daily](#using-renv-daily)
        -   [When I update or install a
            package](#when-i-update-or-install-a-package)
        -   [Getting Updates](#getting-updates)
-   [Help! (light)](#help-light)

A Quick guide for using `renv` . Please refer to the [getting started
vignette](https://rstudio.github.io/renv/articles/renv.html) for more.

# What is `renv`?

A detailed explanation of `renv` can be [found
here](https://rstudio.github.io/renv/articles/renv.html) but, in short,
it is a way to standardize and keep track of R packages across users.

This standardization and transparency is important in the context of
reproducibility: internally, all GLD harmonizers are using the same
versions of R packages and new users can run the code with exactly the
same versions of the R packages that produced the results. This is only
one method we use to ensure our results are reproducible; see [this
explanation for
more](https://rstudio.github.io/renv/articles/renv.html#reproducibility-1).

# How We Use `renv`

While there are many ways to collaborate with `renv` our workflow is set
up with the following tools assumed:

1.  Version control using the [GLD GitHub
    Repository](https://github.com/worldbank/gld). You can, of course,
    clone it and make your own repository and it will work the same.

2.  `.Rproject` file. This file stores a few lines of repository-level
    preferences. `renv` is associated with this `.Rproject` file, and is
    available on the GitHub repository.

3.  `renv.lock` file. This file contains a list of all the package
    names, versions, and information used in the current version of the
    repository — but not the package files themselves. This file is also
    version-controlled on the repository.

## Using `renv` for the first time

Since this `renv` project is already initialized, first-time users will
need to only

``` r
renv::restore()
```

If loaded correctly, the console will tell you that the project `gld` is
loaded with renv.

## Using `renv` daily

Once, you’ve installed and loaded the renv project, whenever Rstudio
loads the `gld.Rproject` file it will automatically load `renv` .

### When I update or install a package

The beauty of `renv` is if one user finds an update or new package for
the project, it will alert the others *somewhat* automatically. But you
have to tell it to do so. First install/update your new package

``` r
install.packages("a brand new package!")
```

Then tell `renv` to save the state of your library. You can also do this
in the UI under “Packages” then `renv`

``` r
renv::snapshot()
```

This updates `renv.lock` file. If you’re keeping track of this file on
GitHub as we are, commit this change to tell others.

### Getting Updates

You see that there’s a new commit on your version control; the
`renv.lock` has been updated in your branch. Pull the update. Then,
either from the UI or in the console,

``` r
renv::restore()
```

This will install the packages that are missing or have been updated.

# Help! (light)

#### If `renv` doesn’t load

Then try

``` r
renv::load()
```

#### `renv::snapshot()` doesn’t detect new packages/updates

Try ensuring that it’s capturing all types of snapshots.

``` r
renv::settings$snapshot.type("all")
renv::snapshot()
```

``` r
citation("renv")
```

    ## 
    ## To cite package 'renv' in publications use:
    ## 
    ##   Kevin Ushey (2021). renv: Project Environments. R package version
    ##   0.14.0. https://CRAN.R-project.org/package=renv
    ## 
    ## A BibTeX entry for LaTeX users is
    ## 
    ##   @Manual{,
    ##     title = {renv: Project Environments},
    ##     author = {Kevin Ushey},
    ##     year = {2021},
    ##     note = {R package version 0.14.0},
    ##     url = {https://CRAN.R-project.org/package=renv},
    ##   }
