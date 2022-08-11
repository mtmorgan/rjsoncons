#' @useDynLib rjsoncons, .registration = TRUE
NULL

.is_scalar_character <-
    function(x)
{
    stopifnot(
        is.character(x),
        length(x) == 1L,
        !is.na(x),
        nzchar(x)
    )
    TRUE
}

#' @rdname jsoncons
#' @md
#'
#' @title Query the jsoncons C++ library
#'
#' @description
#'
#'   `version()` reports the version of the C++ jsoncons library in
#'   use.
#'
#'   `jsonpath()` executes a query against a json string using the
#'   'jsonpath' specification
#'
#'   `jmespath()` executes a query against a json string sing the
#'   'jmespath' specification.
#'
#' @param data character(1) JSON string.
#'
#' @param path character(1) jsonpath or jmespath query string.
#'
#' @return
#'
#'   `version()` returns a character(1) major.minor.patch version
#'   string .
#'
#'   `jsonpath()` aand `jmespath()` return a character(1) json
#'   string representing the result of the query.
#'
#' @examples
#' version()
#'
#' json <- '{
#'   "locations": [
#'     {"name": "Seattle", "state": "WA"},
#'     {"name": "New York", "state": "NY"},
#'     {"name": "Bellevue", "state": "WA"},
#'     {"name": "Olympia", "state": "WA"}
#'   ]
#'  }'
#'
#' jsonpath(json, "$..name") |>
#'     cat("\n")
#'
#' jmespath(json, "locations[?state == 'WA'].name | sort(@)") |>
#'     cat("\n")
#'
#' @export
version <- cpp_version

#' @rdname jsoncons
#'
#' @export
jsonpath <-
    function(data, path)
{
    stopifnot(
        .is_scalar_character(data),
        .is_scalar_character(path)
    )
    cpp_jsonpath(data, path)
}

#' @rdname jsoncons
#'
#' @export
jmespath <-
    function(data, path)
{
    stopifnot(
        .is_scalar_character(data),
        .is_scalar_character(path)
    )
    cpp_jmespath(data, path)
}
