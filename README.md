
# Introduction & Installation

<!-- badges: start -->

<!-- badges: end -->

This package provides the header-only
‘[jsoncons](https://github.com/danielaparker/jsoncons)’ library for
manipulating JSON objects. Use
[rjsoncons](https://github.com/mtmorgan/rjsoncons) for querying JSON or
R objects using ‘JMESpath’ or ‘JSONpath’, or link to the package for
direct access to the C++ library.

Install the released version of this package from CRAN with

``` r
install.packages("rjsoncons", repos = "https://cran.r-project.org")
```

Install the in-development version with

``` r
if (!requireNamespace("remotes", quiety = TRUE))
    install.packages("remotes", repos = "https://cran.r-project.org")
remotes::install_github("mtmorgan/rjsoncons")
```

# Examples

For interactive use, load the library

``` r
library(rjsoncons)
```

The package implements basic functionality, including querying a JSON
document represented as character(1) using
[JSONpath](https://goessner.net/articles/JsonPath/) or
[JMESpath](https://jmespath.org/) syntax. (In the following, `noquote()`
is used to print the result with fewer escaped quotation marks,
increasing readability.)

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

jsonpath(json, "$..name") |>
    noquote()
#> [1] ["Seattle","New York","Bellevue","Olympia"]

jmespath(json, "locations[?state == 'WA'].name | sort(@)") |>
    noquote()
#> [1] ["Bellevue","Olympia","Seattle"]
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
lst <- jsonlite::fromJSON(json, simplifyVector = FALSE)
jmespath(lst, "locations[?state == 'WA'].name | sort(@)", auto_unbox = TRUE) |>
    noquote()
#> [1] ["Bellevue","Olympia","Seattle"]
```

Additional examples illustrating features available are on the help
pages, e.g., `?jmespath`.

# C++ Library Use in Other Packages

The package includes the complete ‘jsoncons’ C++ header-only library,
available to other R packages by adding

    LinkingTo: rjsoncons
    SystemRequirements: C++11

to the DESCRIPTION file. Typical use in an R package would also include
`LinkingTo:` specifications for the
[cpp11](https://cran.r-project.org/package=cpp11) or
[Rcpp](https://cran.r-project.org/package=Rcpp) (this package uses
[cpp11](https://cran.r-project.org/package=cpp11)) packages to provide a
C / C++ interface between R and the C++ ‘jsoncons’ library.

# Session Information

This vignette was compiled using the following software versions

``` r
sessionInfo()
#> R version 4.2.1 (2022-06-23)
#> Platform: x86_64-pc-linux-gnu (64-bit)
#> Running under: Ubuntu 20.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
#> LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices datasets  utils     methods   base     
#> 
#> other attached packages:
#> [1] rjsoncons_0.0.2
#> 
#> loaded via a namespace (and not attached):
#>  [1] codetools_0.2-18 digest_0.6.29    jsonlite_1.8.0   magrittr_2.0.3  
#>  [5] evaluate_0.16    rlang_1.0.4      stringi_1.7.8    renv_0.15.5     
#>  [9] rmarkdown_2.15   tools_4.2.1      stringr_1.4.1    xfun_0.32       
#> [13] yaml_2.3.5       fastmap_1.1.0    compiler_4.2.1   htmltools_0.5.3 
#> [17] knitr_1.39
```
