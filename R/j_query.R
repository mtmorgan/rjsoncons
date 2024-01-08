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
#' @param path_type character(1) type of `path`; one of
#'     `"JSONpointer"`, `"JSONpath"`, `"JMESpath"`. Inferred from
#'     `path` using `j_path_type()`.
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
    function(
        data, path = "", object_names = "asis", as = "string", ...,
        data_type = j_data_type(data), path_type = j_path_type(path)
    )
{
    stopifnot(
        .is_scalar_character(path, z.ok = TRUE),
        object_names %in% c("asis", "sort"),
        as %in% c("string", "R"),
        .is_j_data_type(data_type),
        .is_scalar_character(path_type), path_type %in% j_path_type()
    )

    if (any(c("file", "url") %in% data_type)) {
        data_type <- head(data_type, 1L)
        data <- readLines(data, warn = FALSE)
    }
    data <- .as_json_string(data, ..., data_type = data_type)
    switch(
        data_type[[1]],
        json =,
        R = cpp_j_query(data, path, object_names, as, path_type)
    )
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
    function(
        data, path = "", object_names = "asis", as = "string", ...,
        data_type = j_data_type(data), path_type = j_path_type(path)
    )
{
    stopifnot(
        .is_scalar_character(path, z.ok = TRUE),
        object_names %in% c("asis", "sort"),
        as %in% c("string", "R", "data.frame", "tibble"),
        .is_j_data_type(data_type),
        .is_scalar_character(path_type), path_type %in% j_path_type()
    )

    data <- .as_json_string(data, ..., data_type = data_type)
    switch(
        as,
        string = cpp_j_pivot(data, path, object_names, as, path_type),
        R = cpp_j_pivot(data, path, object_names, as = "R", path_type),
        data.frame =
            cpp_j_pivot(data, path, object_names, as = "R", path_type) |>
            as.data.frame(),
        tibble =
            cpp_j_pivot(data, path, object_names, as = "R", path_type) |>
            tibble::as_tibble()
    )
}
