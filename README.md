# rjsoncons

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rjsoncons)](https://CRAN.R-project.org/package=rjsoncons)
![CRAN downloads](https://cranlogs.r-pkg.org/badges/last-month/rjsoncons)
<!-- badges: end -->

The [jsoncons][] C++ header-only library constructs representations
from a JSON character vector, and provides extensions for flexible
queries and other operations on JSON objects. This package provides
'R' functions to query (filter or transform) and pivot (convert from
array-of-objects to object-of-arrays, for easy import into 'R') 'JSON'
or 'NDJSON' strings or files using [JSONpath][], [JMESpath][], and
[JSONpointer][] expressions. The package also makes it easy to use C++
'jsoncons' in other *R* packages for direct access to 'C++'
functionality.

[JSONpath]: https://goessner.net/articles/JsonPath/
[JMESpath]: https://jmespath.org/
[JSONpointer]: https://datatracker.ietf.org/doc/html/rfc6901

## Installation and loading

Install the released package version from CRAN

``` r
install.packages("rjsoncons", repos = "https://CRAN.R-project.org")
```

Install the development version with

``` r
if (!requireNamespace("remotes", quiety = TRUE))
    install.packages("remotes", repos = "https://CRAN.R-project.org")
remotes::install_github("mtmorgan/rjsoncons")
```

Attach the installed package to your *R* session with

``` r
library(rjsoncons)
```

[jsoncons]: https://github.com/danielaparker/jsoncons/
[rjsoncons]: https://mtmorgan.github.io/rjsoncons/

## Use cases

The [introductory vignette][] outlines common use cases, including:

- Filtering large JSON documents to extract records of interest.
- Extracting deeply nested elements.
- Transforming data for more direct incorporation in *R* data structures.

The [jsoncons][] C++ header-only library is a very useful starting
point for advanced JSON manipulation. The vignette outlines how
[rjsoncons][] can be used by other *R* packages wishing to access the
C++ library.

## Next steps

See the [introductory vignette][] for additional details.

[introductory vignette]: https://mtmorgan.github.io/rjsoncons/articles/rjsoncons.html
