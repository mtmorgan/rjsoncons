#' @rdname paths_and_pointer
#'
#' @title JSONpath, JMESpath, or JSONpointer query of JSON / NDJSON documents
#'
#' @description `jsonpath()` executes a query against a JSON string or
#'     vector NDJSON entries using the 'JSONpath' specification.
#'
#' @param data a character() JSON string or NDJSON records, or an *R*
#'     object parsed to a JSON string using `jsonlite::toJSON()`.
#'
#' @param path character(1) JSONpointer, JSONpath or JMESpath query
#'     string.
#'
#' @param object_names character(1) order `data` object elements
#'     `"asis"` (default) or `"sort"` before filtering on `path`.
#'
#' @param as character(1) return type. `"string"` returns a single
#'     JSON string; `"R"` returns an *R* object following the rules
#'     outlined for `as_r()`.
#'
#' @param ...
#'
#' arguments for parsing NDJSON, or passed to `jsonlite::toJSON` when
#' `data` is not character-valued. For NDJSON,
#'
#' - Use `n_records = 2` to parse just the first two records of the
#'   NDJSON document.
#' - Use `verbose = TRUE` to obtain a progress bar when reading from a
#'   connection (file or URL). Requires the cli package.
#'
#' As an example for use with `jsonlite::toJSON()`
#'
#' - use `auto_unbox = TRUE` to automatically 'unbox' vectors of
#'   length 1 to JSON scalar values.
#'
#' @return `jsonpath()`, `jmespath()` and `jsonpointer()` return a
#'     character(1) JSON string (`as = "string"`, default) or *R*
#'     object (`as = "R"`) representing the result of the query.
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
#' jsonpath(json_obj, "$")           |> cat("\n")
#' jsonpath(json_obj, "$.*")         |> cat("\n")
#' jsonpath(json_obj, "$", "sort")   |> cat("\n")
#' jsonpath(json_obj, "$.*", "sort") |> cat("\n")
#'
#' @export
jsonpath <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    j_query(data, path, object_names, as, ..., path_type = "JSONpath")
}

#' @rdname paths_and_pointer
#'
#' @description `jmespath()` executes a query against a JSON string
#'     using the 'JMESpath' specification.
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
    j_query(data, path, object_names, as, ..., path_type = "JMESpath")
}

#' @rdname paths_and_pointer
#'
#' @description `jsonpointer()` extracts an element from a JSON string
#'     using the 'JSON pointer' specification.
#'
#' @examples
#' ## jsonpointer 0-based arrays
#' jsonpointer(json, "/locations/0/name")
#'
#' ## document root "", sort selected element keys
#' jsonpointer('{"b": 0, "a": 1}', "", "sort", as = "R") |>
#'     str()
#'
#' ## 'Key not found' -- path '/' searches for a 0-length key
#' try(jsonpointer('{"b": 0, "a": 1}', "/"))
#'
#' @export
jsonpointer <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    j_query(data, path, object_names, as, ..., path_type = "JSONpointer")
}
