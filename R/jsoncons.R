#' @useDynLib rjsoncons, .registration = TRUE
NULL

.is_scalar_character <-
    function(x)
{
    all(
        is.character(x),
        length(x) == 1L,
        !is.na(x),
        nzchar(x)
    )
}

#' @importFrom jsonlite toJSON
.as_json_string <-
    function(x, ...)
{
    if (.is_scalar_character(x) && !inherits(x, "AsIs")) {
        x
    } else {
        as.character(toJSON(x, ...))
    }
}

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
version <- cpp_version

#' @rdname jsoncons
#'
#' @description `jsonpath()` executes a query against a json string
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
#' @param ... arguments passed to `jsonlite::toJSON` when `data` is
#'     not a scalar character vector. For example, use `auto_unbox =
#'     TRUE` to automatically 'unbox' vectors of length 1 to JSON
#'     scalar values.
#'
#' @return `jsonpath()` returns a character(1) json string
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
#' jsonpath(json, "$..name") |>
#'     cat("\n")
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
#' try(jsonpath("Seattle", "$[0]"))
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
    function(data, path, object_names = "asis", ...)
{
    stopifnot(
        .is_scalar_character(path),
        .is_scalar_character(object_names)
    )
    data <- .as_json_string(data, ...)
    cpp_jsonpath(data, path, object_names)
}

#' @rdname jsoncons
#'
#' @description `jmespath()` executes a query against a json string
#'     using the 'jmespath' specification.
#'
#' @return `jmespath()` return a character(1) json string representing
#'     the result of the query.
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
    function(data, path, object_names = "asis", ...)
{
    stopifnot(
        .is_scalar_character(path),
        .is_scalar_character(object_names)
    )
    data <- .as_json_string(data, ...)
    cpp_jmespath(data, path, object_names)
}
