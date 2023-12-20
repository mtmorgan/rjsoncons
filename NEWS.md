# rjsoncons 1.2.0

- (v.1.1.0.9100) update jsoncons library to 173.2, relaxing compiler
  requirements to c++11.
- (v.1.1.0.9000) implement `jsonpivot()` to transform JSON
  array-of-objects to object-of-arrays, a common step before
  representation as a data.frame.

# rjsoncons 1.1.0

- (1.1.0) CRAN release
- (1.0.1.9100) using jsonlite (e.g., 'toJSON()' for parsing R objects)
  requires separate installation of jsonlite.
- (1.0.1.9000) update jsoncons library to 0.172.1; addresses segfault
  on 'fedora' CRAN builder

# rjsoncons 1.0.1

- (1.0.1) CRAN release
- (1.0.0.9200) use pkgdown
- (1.0.0.9100) parse JSON to R with `as = "R"` argument and `as_r()`

# rjsoncons 1.0.0

- (1.0.0) initial CRAN release
- (0.0.99) pre-release version
- (0.0.3) support object names ordering 'asis' or 'sort'
- (0.0.3) DESCRIPTION file updates: correct 'Title:' capitalization;
  avoid warnings about most misspellings
- (0.0.3) Add github action to rebuild README.md from
  vignettes/rjsoncons.Rmd
- (0.0.2) jsoncons library update
- (0.0.2) support for R object query in addition to JSON string
- (0.0.2) add unit tests
- (0.0.2) R and minor C++ code refactoring
- (0.0.1) initial C++ / R implementation of `jmespath()` / `jsonpath()`
