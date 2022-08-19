
# Introduction & Installation

<!-- badges: start -->
<!-- badges: end -->

This package provides the header-only
‘[jsoncons](https://github.com/danielaparker/jsoncons)’ library for
manipulating JSON objects. Install the released version of this package
from CRAN with

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
#> R version 4.2.1 Patched (2022-06-23 r82518)
#> Platform: aarch64-apple-darwin21.5.0 (64-bit)
#> Running under: macOS Monterey 12.5
#> 
#> Matrix products: default
#> BLAS:   /Users/ma38727/bin/R-4-2-branch/lib/libRblas.dylib
#> LAPACK: /Users/ma38727/bin/R-4-2-branch/lib/libRlapack.dylib
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] rjsoncons_0.0.2
#> 
#> loaded via a namespace (and not attached):
#>  [1] codetools_0.2-18 digest_0.6.29    jsonlite_1.8.0   magrittr_2.0.3  
#>  [5] evaluate_0.15    rlang_1.0.4      stringi_1.7.8    cli_3.3.0       
#>  [9] rmarkdown_2.14   tools_4.2.1      stringr_1.4.0    xfun_0.31       
#> [13] yaml_2.3.5       fastmap_1.1.0    compiler_4.2.1   htmltools_0.5.3 
#> [17] knitr_1.39
```
