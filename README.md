
# rjsoncons

<!-- badges: start -->
<!-- badges: end -->

This package provides the header-only
‘[jsoncons](https://github.com/danielaparker/jsoncons)’ library for
manipulating json objects.

## Installation

Install the in-development version of this package with

``` r
if (!requireNamespace("BiocManager", quiety = TRUE))
    install.packages("BiocManager", repos = "https://cran.r-project.org")
BiocManager::install("mtmorgan/rjsoncons")
```

## Example

For interactive use, load the library

``` r
library(rjsoncons)
```

The package implements basic functionality, including querying a JSON
document represent as character(1) using
[JSONpath](https://goessner.net/articles/JsonPath/) or
[JMESpath](https://jmespath.org/) syntax.

``` r
rjsoncons::version()  # C++ library version
#> [1] "0.168.7"

json <- '{
  "locations": [
    {"name": "Seattle", "state": "WA"},
    {"name": "New York", "state": "NY"},
    {"name": "Bellevue", "state": "WA"},
    {"name": "Olympia", "state": "WA"}
  ]
}'

jsonpath(json, "$..name")
#> [1] "[\"Seattle\",\"New York\",\"Bellevue\",\"Olympia\"]"

jmespath(json, "locations[?state == 'WA'].name | sort(@)")
#> [1] "[\"Bellevue\",\"Olympia\",\"Seattle\"]"
```

For an R representation of the results use, e.g.,
[jsonlite](https://cran.r-project.org/package=jsonlite)

``` r
jmespath(json, "locations[?state == 'WA'].name | sort(@)") |>
    jsonlite::fromJSON()
#> [1] "Bellevue" "Olympia"  "Seattle"
```

It is also possible to provide list-of-list style *R* objects that are
converted using `jsonlite::toJSON()` before queries are made; `toJSON()`
arguments like `auto_unbox = TRUE` can be added to the function call.

``` r
lst <- fromJSON(json, simplifyVector = FALSE)
jmespath(lst, "locations[?state == 'WA'].name | sort(@)", auto_unbox = TRUE)
#> [1] "[\"Bellevue\",\"Olympia\",\"Seattle\"]"
```

## Library use in other packages

The package includes the complete jsoncons C++ header-only library,
available to other R packages by adding

    LinkingTo: rjsoncons
    SystemRequirements: C++11

to the DESCRIPTION file. Typical use in an R package would also include
`LinkingTo:` specifications for the
[cpp11](https://cran.r-project.org/package=cpp11) or
[Rcpp](https://cran.r-project.org/package=Rcpp) (this package uses
cpp11) packages to provide a C / C++ interface between R and the C++
jsoncons library.
