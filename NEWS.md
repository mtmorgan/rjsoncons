# rjsoncons 1.3.1

- (1.3.0.9200) bug fix: NDJSON `j_pivot('{"a": [1,2]}')` now pivots as
  `'{"a": [[1,2]]}'`. NDJSON `j_pivot()` records must *always* be
  objects.
- (1.3.0.9100) add JSONPath to examples article.
- (1.3.0.9100) make robust to 'noSuggests' CRAN checks.

# rjsoncons 1.3.0

- (1.2.0.9900) better support `j_pivot()` when keys differ between
  objects.
- (1.2.0.9800) add JSON schema support with `j_schema_is_valid()`,
  `j_schema_validate()`.
- (1.2.0.9704) add key and value search with `j_flatten()`,
  `j_find_*()` supporting JSONpointer and JSONpath.
- (1.2.0.9602) compile on Ubuntu 18.04
  <https://github.com/mtmorgan/rjsoncons/issues/3>
- (1.2.0.9503) add JSON patch support with `j_patch_apply()`,
  `j_patch_from()`, and `j_patch_op()`.
- (1.2.0.9401) internal C++ code cleanup and refactoring.
- (1.2.0.9300) add 'Examples' web-only vignette.
- (1.2.0.9201) restore progress bar on NDJSON parsing.
- (1.2.0.9100) `as_r()` supports file and url connections; improved
  connection implementation using C++ stream buffer.
- (1.2.0.9000) bug fix: support JSON `j_pivot()` file / url connections.

# rjsoncons 1.2.0

- (1.2.0) CRAN release.
- (1.1.0.9500) update documentation, include NDJSON-specific, web-only
  vignette.
- (1.1.0.9400) support NDJSON and file / url connections.
- (1.1.0.9300) implement `j_query()` (query without requiring path.
  specification), `j_pivot()`, and `j_path_type()`. Remove
  `jsonpivot()`.
- (1.1.0.9200) implement `jsonpointer()` for querying JSON documents.
- (1.1.0.9100) update jsoncons library to 173.2, relaxing compiler
  requirements to c++11.
- (1.1.0.9000) implement `jsonpivot()` to transform JSON.
  array-of-objects to object-of-arrays, a common step before
  representation as a data.frame.

# rjsoncons 1.1.0

- (1.1.0) CRAN release.
- (1.0.1.9100) using jsonlite (e.g., 'toJSON()' for parsing R objects).
  requires separate installation of jsonlite.
- (1.0.1.9000) update jsoncons library to 0.172.1; addresses segfault
  on 'fedora' CRAN builder.

# rjsoncons 1.0.1

- (1.0.1) CRAN release.
- (1.0.0.9200) use pkgdown.
- (1.0.0.9100) parse JSON to R with `as = "R"` argument and `as_r()`.

# rjsoncons 1.0.0

- (1.0.0) initial CRAN release.
- (0.0.99) pre-release version.
- (0.0.3) support object names ordering 'asis' or 'sort'.
- (0.0.3) DESCRIPTION file updates: correct 'Title:' capitalization;
  avoid warnings about most misspellings.
- (0.0.3) Add GitHub action to rebuild README.md from
  vignettes/rjsoncons.Rmd.
- (0.0.2) jsoncons library update.
- (0.0.2) support for R object query in addition to JSON string.
- (0.0.2) add unit tests.
- (0.0.2) R and minor C++ code refactoring.
- (0.0.1) initial C++ / R implementation of `jmespath()` / `jsonpath()`.
