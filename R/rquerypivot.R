.j_valid <-
    function(data_type, object_names, path, path_type, n_records, verbose, ...)
{
    stopifnot(
        .is_scalar_character(path, z.ok = TRUE),
        object_names %in% c("asis", "sort"),
        .is_scalar_numeric(n_records),
        .is_scalar_logical(verbose),
        .is_j_data_type(data_type),
        .is_scalar_character(path_type),
        path_type %in% j_path_type(),
        ...
    )
}

#' @rdname rquerypivot
#'
#' @title Query and pivot JSON and NDJSON documents
#'
#' @description `j_query()` executes a query against a JSON or NDJSON
#'     document, automatically inferring the type of `data` and
#'     `path`.
#'
#' @param as character(1) return type. For `j_query()`, `"string"`
#'     returns JSON / NDJSON strings; `"R"` parses JSON / NDJSON to R
#'     using rules in `as_r()`. For `j_pivot()` (JSON only), use `as =
#'     "data.frame"` or `as = "tibble"` to coerce the result to a
#'     data.frame or tibble.
#'
#' @inheritParams jsonpath
#'
#' @param ... passed to `jsonlite::toJSON` when `data` is an *R* object.
#' 
#' @param n_records numeric(1) maximum number of NDJSON records parsed.
#'
#' @param verbose logical(1) report progress when parsing large NDJSON
#'     files.
#'
#' @param data_type character(1) type of `data`; one of `"json"`,
#'     `"ndjson"`, or a value returned by `j_data_type()`.
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
#' ## a few NDJSON records from <https://www.gharchive.org/>
#' ndjson_file <-
#'     system.file(package = "rjsoncons", "extdata", "2023-02-08-0.json")
#' j_query(ndjson_file, "{id: id, type: type}")
#'
#' @export
j_query <-
    function(
        data, path = "", object_names = "asis", as = "string", ...,
        n_records = Inf, verbose = FALSE,
        data_type = j_data_type(data), path_type = j_path_type(path)
    )
{
    .j_valid(data_type, object_names, path, path_type, n_records, verbose)
    stopifnot(.is_scalar_character(as), as %in% c("string", "R"))

    data <- .as_json_string(data, data_type, ...)
    result <- do_cpp(
        cpp_j_query, cpp_j_query_con,
        data, data_type, object_names, as, path, path_type,
        n_records = n_records, verbose = verbose
    )

    if (data_type[[1]] %in% c("json", "R"))
        result <- result[[1]]

    result
}

#' @rdname rquerypivot
#'
#' @description `j_pivot()` transforms a JSON array-of-objects to an
#'     object-of-arrays; this can be useful when forming a
#'     column-based tibble from row-oriented JSON / NDJSON.
#'
#' @details
#'
#' `j_pivot()` transforms an 'array-of-objects' (typical when the JSON
#' is a row-oriented representation of a table) to an
#' 'object-of-arrays'. A simple example transforms an array of two
#' objects each with three fields `'[{"a": 1, "b": 2, "c": 3}, {"a":
#' 4, "b": 5, "c": 6}]'` to an object with three fields, each a vector
#' of length 2 `'{"a": [1, 4], "b": [2, 5], "c": [3, 6]}'`. The
#' object-of-arrays representation corresponds closely to an _R_
#' data.frame or tibble, as illustrated in the examples.
#'
#' `j_pivot()` with JMESpath paths are especially useful for
#' transforming NDJSON to a `data.frame` or `tibble`
#'
#' @examples
#' j_pivot(json, "$.locations[?@.state=='WA']", as = "string")
#' j_pivot(json, "locations[?@.state=='WA']", as = "R")
#' j_pivot(json, "locations[?@.state=='WA']", as = "data.frame")
#' j_pivot(json, "locations[?@.state=='WA']", as = "tibble")
#'
#' ## use 'path' to pivot ndjson one record at at time
#' j_pivot(ndjson_file, "{id: id, type: type}", as = "data.frame")
#'
#' ## 'org' is a nested element; extract it
#' j_pivot(ndjson_file, "org", as = "data.frame")
#'
#' ## use j_pivot() to filter 'PushEvent' for organizations
#' path <- "[{id: id, type: type, org: org}]
#'              [?@.type == 'PushEvent' && @.org != null] |
#'                  [0]"
#' j_pivot(ndjson_file, path, as = "data.frame")
#'
#' ## try also
#' ##
#' ##     j_pivot(ndjson_file, path, as = "tibble") |>
#' ##         tidyr::unnest_wider("org", names_sep = ".")
#' @export
j_pivot <-
    function(
        data, path = "", object_names = "asis", as = "string", ...,
        n_records = Inf, verbose = FALSE,
        data_type = j_data_type(data), path_type = j_path_type(path)
    )
{
    .j_valid(data_type, object_names, path, path_type, n_records, verbose)
    stopifnot(as %in% c("string", "R", "data.frame", "tibble"))

    data <- .as_json_string(data, data_type, ...)
    as0 <- ifelse(identical(as, "string"), "string", "R")
    pivot <- do_cpp(
        cpp_j_pivot, cpp_j_pivot_con,
        data, data_type, object_names, as0, path, path_type, 
        n_records = n_records, verbose = verbose
    )

    ## process pivot return types to output form
    if (identical(as, "string")) {
        result <- unlist(pivot, recursive = TRUE)
    } else if (.is_j_data_type_connection(data_type)) {
        ## unnest list-of-named chunks
        keys <- names(pivot[[1]])
        names(keys) <- keys
        result <- lapply(keys, \(key, pivot) {
            do.call("c", lapply(pivot, `[[`, key))
        }, pivot)
    } else {
        result <- pivot[[1]]
    }

    switch(
        as,
        string = result,
        R = result,
        data.frame = as.data.frame(result),
        tibble = tibble::as_tibble(result)
    )
}
