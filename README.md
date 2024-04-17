# rjsoncons

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rjsoncons)](https://CRAN.R-project.org/package=rjsoncons)
![CRAN downloads](https://cranlogs.r-pkg.org/badges/last-month/rjsoncons)
<!-- badges: end -->

This package provides functions to query (filter or transform), pivot
(convert from array-of-objects to object-of-arrays, for easy import as
'R' data frame), search, patch (edit), and validate (against [JSON
Schema][]) 'JSON' and 'NDJSON' strings, files, or URLs. Query and
pivot support [JSONpointer][], [JSONpath][] or [JMESpath][]
expressions. The implementation uses the [jsoncons][] header-only
library; the library is easily linked to other packages for direct
access to 'C++' functionality not implemented here.

[JSON Schema]: https://json-schema.org
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

- Filter large JSON or NDJSON documents to extract records or elements
  of interest.
- Extract deeply nested elements.
- Transform data for more direct incorporation in *R* data structures.
- 'Patch' JSON strings programmatically, e.g., to update HTTP request
  payloads.
- Validate JSON documents against JSON schemas

The [jsoncons][] C++ header-only library is a very useful starting
point for advanced JSON manipulation. The vignette outlines how
[rjsoncons][] can be used by other *R* packages wishing to access the
C++ library.

## Next steps

See the [introductory vignette][] for additional details.

[introductory vignette]: https://mtmorgan.github.io/rjsoncons/articles/a_rjsoncons.html
