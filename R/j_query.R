#' @rdname j_query
#'
#' @title Query and pivot for JSON documents
#'
#' @description `j_query()` executes a query against a JSON
#'     document, automatically inferring the type of `path`.
#'
#' @param as character(1) return type. For `j_query()`, `"string"`
#'     returns a single JSON string; `"R"` parses the JSON to R using
#'     rules in `as_r()`. For `j_pivot()`, use `as = "data.frame"` or
#'     `as = "tibble"` to coerce the result to a data.frame or tibble.
#'
#' @inheritParams jsonpath
#'
#' @examples
#' json <- '{
#'   "locations": [
#'     {"name": "Seattle", "state": "WA"},
#'     {"name": "New York", "state": "NY"},
#'     {"name": "Bellevue", "state": "WA"},
#'     {"name": "Olympia", "state": "WA"}
#'   ]
#' }'
#'
#' j_query(json, "/locations/0/name")             # JSONpointer
#' j_query(json, "$.locations[*].name", as = "R") # JSONpath
#' j_query(json, "locations[].state", as = "R")   # JMESpath
#'
#' @export
j_query <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    stopifnot(
        as %in% c("string", "R")
    )

    FUN <- switch(
        j_path_type(path),
        JSONpointer = jsonpointer,
        JSONpath = jsonpath,
        JMESpath = jmespath
    )
    FUN(data, path, object_names = object_names, as = as, ...)
}

j_pivot_impl <-
    function(data, object_names = "asis", as = "string", ...)
{
    stopifnot(
        .is_scalar_character(object_names),
        .is_scalar_character(as)
    )

    data <- .as_json_string(data, ...)
    cpp_j_pivot(data, object_names, as)
}


#' @rdname j_query
#'
#' @description `j_pivot()` transforms a JSON array-of-objects to an
#'     object-of-arrays; this can be useful when forming a
#'     column-based tibble from row-oriented JSON.
#'
#' @details
#'
#' `j_pivot()` transforms an 'array-of-objects' (typical when the
#' JSON is a row-oriented representation of a table) to an
#' 'object-of-arrays'. A simple example transforms an array of two
#' objects each with three fields `'[{"a": 1, "b": 2, "c": 3}, {"a":
#' 4, "b": 5, "c": 6}]'` to an object with with three fields, each a
#' vector of length 2 `'{"a": [1, 4], "b": [2, 5], "c": [3, 6]}'`. The
#' object-of-arrays representation corresponds closely to an _R_
#' data.frame or tibble, as illustrated in the examples.
#'
#' @examples
#' j_pivot(json, "$.locations[?@.state=='WA']", as = "string")
#' j_pivot(json, "locations[?@.state=='WA']", as = "R")
#' j_pivot(json, "locations[?@.state=='WA']", as = "data.frame")
#' j_pivot(json, "locations[?@.state=='WA']", as = "tibble")
#'
#' @export
j_pivot <-
    function(data, path, object_names = "asis", as = "string", ...)
{
    stopifnot(
        as %in% c("string", "R", "data.frame", "tibble")
    )

    if (!missing(path))
        data <- j_query(data, path, object_names, as = "string", ...)

    switch(
        as,
        string = j_pivot_impl(data, object_names, as = "string", ...),
        R = j_pivot_impl(data, object_names, as = "R", ...),
        data.frame =
            j_pivot_impl(data, object_names, as = "R", ...) |>
            as.data.frame(),
        tibble =
            j_pivot_impl(data, object_names, as = "R", ...) |>
            tibble::as_tibble()
    )
}

#' @rdname j_query
#'
#' @description `j_path_type()` uses simple rules to identify
#'     whether `path` is a JSONpointer, JSONpath, or JMESpath
#'     expression.
#'
#' @details
#'
#' `j_path_type()` infers the type of `path` using a simple but
#' incomplete calssification:
#'
#' - `"JSONpointer"` is infered if the the path is `""` or starts with `"/"`.
#' - `"JSONpath"` expressions start with `"$"`.
#' - `"JMESpath"` expressions satisfy niether the `JSONpointer` nor
#'   `JSONpath` criteria.
#'
#' Because of these rules, the valid JSONpointer path `"@"` is
#' interpretted as JMESpath; use `jsonpointer()` if JSONpointer
#' behavior is required.
#'
#' @param path `character(1)` used to query the JSON document.
#'
#' @examples
#' j_path_type("")
#' j_path_type("/locations/0/name")
#' j_path_type("$.locations[0].name")
#' j_path_type("locations[0].name")
#'
#' @export
j_path_type <-
    function(path)
{
    stopifnot(
        .is_scalar_nchar_0(path) || .is_scalar_character(path)
    )

    path <- trimws(path)
    if (.is_scalar_nchar_0(path)) {
        "JSONpointer"
    } else {
        switch(
            substring(path, 1, 1),
            "/" = "JSONpointer",
            "$" = "JSONpath",
            "JMESpath"
        )
    }
}

