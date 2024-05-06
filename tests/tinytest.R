## Suggests: dependencies
has_jsonlite <- requireNamespace("jsonlite", quietly = TRUE)

if (requireNamespace("tinytest", quietly = TRUE))
    tinytest::test_package("rjsoncons")
