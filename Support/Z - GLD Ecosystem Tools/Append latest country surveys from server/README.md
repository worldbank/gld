# GLD latest surveys appending function

## What is the issue?

The Global Labor Database (GLD) is a live database that is updated constantly. No only do we add new surveys, but we also update already published surveys if we spot or are notified of an error and correct it. If you spot something, please reach out by either [creating an issue](https://github.com/worldbank/gld/issues/new/choose) or writing to <gld@worldbank.org>.

Moreover, you probably want to have all surveys for a country loaded into one neat file at once. How to make sure you have this and be certain they are the latest? If you ahve access to the GLD server, run our `gld_append_country_latest` function!

## How is it addressed?

The Micro Data Library (MDL) folder and file naming convention ensures that the latest file is also the last in alphanumeric ordering. This is leveraged to organise the files into a list of the latest survey for each year, so that we may append all files on that list.

## How to run the code?

### Installing the code

The first thing is to install the programme. This can be done directly from the internet by typing the following into the console:

```
net install gld_append_country_latest, replace from("https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/Append%20latest%20country%20surveys%20from%20server")
```

Make sure to keep the `replace` option. This is not necessary the first time but will allow Stata to overwrite the code if we update this function (and now you would need alert for those updates, technically. It never ends... Sorry! Much less likely, though).

### Function Inputs

The `gld_append_country_latest` function takes the following inputs:

1. `folder_path`: The path to the folder containing the country's GLD files on the server.
2. `start_year`: The starting year to consider
3. `end_year`: The ending year to consider. 

### Function Logic

The function performs the following steps:

1. **Evaluate input on folder_path**: It checks if the specified folder path exists. If not, it displays an error message and exits.
2. **Evaluate input on years**: It checks if the provided start and end years are valid. If the start year is before 1920, it displays an error message and exits. It also ensures that the start year is not larger than the end year.
3. **Create list of latest surveys**: The function reads in a list of all the GLD files in the specified folder, filters to include only the harmonized files, and then identifies the most recent version of each survey by using the version information in the file names.
4. **Append latest surveys**: Finally, the function appends all the identified latest GLD files for the specified country and years.

### Usage

To use the `gld_append_country_latest` function, you can call it with the required and optional parameters:

```
gld_append_country_latest, folder_path("/path/to/country/folder") [start_year(YYYY) end_year(ZZZZ)]
```

This will load and append all the latest harmonized GLD files for the specified country, restricting the data to the years between YYYY and ZZZZ (inclusive).

### Example

```
gld_append_country_latest, folder_path("Y:/GLD-Public/ZAF") start_year(2010) end_year(2019)
```

This will load and append all the latest harmonized GLD files for South Africa (ZAF), restricting the data to the years between 2010 and 2019 (inclusive).
