#' @useDynLib rjsoncons, .registration = TRUE
NULL

#' @rdname jsoncons
#'
#' @title Query the jsoncons C++ library
#'
#' @description `version()` reports the version of the C++ jsoncons
#'     library in use.
#'
#' @return `version()` returns a character(1) major.minor.patch
#'     version string .
#'
#' @examples
#' version()
#'
#' @export
version <-
    function()
{
    paste0(cpp_version(), " (update bbaf3b73b)")
}

#' @rdname jsoncons
#'
#' @description `jsonpath()` executes a query against a JSON string
#'     using the 'jsonpath' specification
#'
#' @param data an _R_ object. If `data` is a scalar (length 1)
#'     character vector, it is treated as a single JSON
#'     string. Otherwise, it is parsed to a JSON string using
#'     `jsonlite::toJSON()`. Use `I()` to treat a scalar character
#'     vector as an _R_ object rather than JSON string, e.g., `I("A")`
#'     will be parsed to `["A"]` before processing.
#'
#' @param path character(1) jsonpath or jmespath query string.
#'
#' @param object_names character(1) order `data` object elements
#'     `"asis"` (default) or `"sort"` before filtering on `path`.
#'
#' @param as character(1) return type. `"string"` returns a single
#'     JSON string; `"R"` returns an *R* object following the rules
#'     outlined below.
#'
#' @param ... arguments passed to `jsonlite::toJSON` when `data` is
#'     not a scalar character vector. For example, use `auto_unbox =
#'     TRUE` to automatically 'unbox' vectors of length 1 to JSON
#'     scalar values.
#'
#' @return `jsonpath()` and `jmespath()` return a character(1) JSON
#'     string (`as = "string"`, default) or *R* object (`as = "R"`)
#'     representing the result of the query.
#'
#' @examples
#' json <- '{
#'   "locations": [
#'     {"name": "Seattle", "state": "WA"},
#'     {"name": "New York", "state": "NY"},
#'     {"name": "Bellevue", "state": "WA"},
#'     {"name": "Olympia", "state": "WA"}
#'   ]
#'  }'
#'
#' ## return a JSON string
#' jsonpath(json, "$..name") |>
#'     cat("\n")
#'
#' ## return an R object
#' jsonpath(json, "$..name", as = "R")
#'
#' ## create a list with state and name as scalar vectors
#' lst <- jsonlite::fromJSON(json, simplifyVector = FALSE)
#'
#' ## objects other than scalar character vectors are automatically
#' ## coerced to JSON; use `auto_unbox = TRUE` to represent R scalar
#' ## vectors in the object as JSON scalar vectors
#' jsonpath(lst, "$..name", auto_unbox = TRUE) |>
#'     cat("\n")
#'
#' ## a scalar character vector like "Seattle" is not valid JSON...
#' try(jsonpath("Seattle", "$"))
#' ## ...but a double-quoted string is
#' jsonpath('"Seattle"', "$")
#'
#' ## use I("Seattle") to coerce to a JSON object ["Seattle"]
#' jsonpath(I("Seattle"), "$[0]")      |> cat("\n")
#'
#' ## different ordering of object names -- 'asis' (default) or 'sort'
#' json_obj <- '{"b": "1", "a": "2"}'
#' jsonpath(json_obj, "$")             |> cat("\n")
#' jsonpath(json_obj, "$.*")           |> cat("\n")
#' jsonpath(json_obj, "$", "sort")   |> cat("\n")
#' jsonpath(json_obj, "$.*", "sort") |> cat("\n")
#'
#' @export
jsonpath <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    stopifnot(
        .is_scalar_character(path),
        .is_scalar_character(object_names)
    )
    data <- .as_json_string(data, ...)
    cpp_jsonpath(data, path, object_names, as)
}

#' @rdname jsoncons
#'
#' @description `jmespath()` executes a query against a JSON string
#'     using the 'jmespath' specification.
#'
#' @examples
#' path <- "locations[?state == 'WA'].name | sort(@)"
#' jmespath(json, path) |>
#'     cat("\n")
#'
#' ## original filter always fails, e.g., '["WA"] != 'WA'
#' jmespath(lst, path)  # empty result set, '[]'
#'
#' ## filter with unboxed state, and return unboxed name
#' jmespath(lst, "locations[?state[0] == 'WA'].name[0] | sort(@)") |>
#'     cat("\n")
#'
#' ## automatically unbox scalar values when creating the JSON string
#' jmespath(lst, path, auto_unbox = TRUE) |>
#'     cat("\n")
#'
#' @export
jmespath <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    stopifnot(
        .is_scalar_character(path),
        .is_scalar_character(object_names),
        .is_scalar_character(as)
    )
    data <- .as_json_string(data, ...)
    cpp_jmespath(data, path, object_names, as)
}

#' @rdname jsoncons
#'
#' @description `as_r()` transforms a JSON string to an *R* object.
#'
#' @details
#'
#' The `as = "R"` argument to `jsonpath()` and `jmespath()` and
#' `as_r()` transform a JSON string representation to an *R*
#' object. Main rules are:
#'
#' - JSON arrays of a single type (boolean, integer, double, string)
#'   are transformed to *R* vectors of the same length and
#'   corresponding type. A JSON scalar and a JSON vector of length 1
#'   are represented in the same way in *R*.
#'
#' - If a JSON 64-bit integer array contains a value larger than *R*'s
#'   32-bit integer representation, the array is transformed to an *R*
#'   numeric vector. NOTE that this results in loss of precision for
#'   64-bit integer values greater than `2^53`.
#'
#' - JSON arrays mixing integer and double values are transformed to
#'   *R* numeric vectors.
#'
#' - JSON objects are transformed to *R* named lists.
#'
#' The vignette reiterates this information and provides additional
#' details.
#'
#' @examples
#' ## as_r()
#' as_r('[1, 2, 3]')       # JSON integer array -> R integer vector
#' as_r('[1, 2.0, 3]')     # JSON intger and double array -> R numeric vector
#' as_r('[1, 2.0, "3"]')   # JSON mixed array -> R list
#' as_r('[1, 2147483648]') # JSON integer > R integer max -> R numeric vector
#'
#' json = '{"b": 1, "a": ["c", "d"], "e": true, "f": [true], "g": {}}'
#' as_r(json) |> str()     # parsing complex objects
#' identical(              # JSON scalar and length 1 array identical in R
#'     as_r('{"a": 1}'), as_r('{"a": [1]}')
#' )
#'
#' @return `as_r()` returns an *R* object.
#'
#' @export
as_r <-
    function(data, object_names = "asis", ...)
{
    stopifnot(
        .is_scalar_character(data),
        .is_scalar_character(object_names)
    )

    data <- .as_json_string(data, ...)
    cpp_as_r(data, object_names)
}
