## internal implementation of .j_flatten, always returns a list to
## simplify j_find_*() processing of both JSON & NDJSON
.j_flatten <-
    function(data, object_names, as, ..., n_records, verbose, data_type)
{
    ## initialize constants to enable code re-use
    path <- ""
    path_type <- j_path_type(path)

    ## validity
    .j_valid(data_type, object_names, path, path_type, n_records, verbose)

    data <- .as_json_string(data, data_type, ...)
    result <- do_cpp(
        cpp_j_flatten, cpp_j_flatten_con,
        data, data_type, object_names, as, path, path_type,
        n_records = n_records, verbose = verbose
    )
}

## internal function calling grepl with argument list
.j_find_grepl <-
    function(pattern, x, grep_args)
{
    stopifnot(
        is.list(grep_args),
        all(
            names(grep_args) %in%
            setdiff(names(formals(grepl)), c("pattern", "x"))
        )
    )
    args <- c(list(pattern = pattern, x = x), grep_args)
    do.call(grepl, args)
}

## internal function to format j_find_*() result
.j_find_format <-
    function(flattened, as, data_type)
{
    result <- lapply(flattened, function(json_record, as) {
        if (identical(as, "R")) {
            json_record
        } else {
            keys <- names(json_record)
            values <- unlist(json_record, use.names = FALSE)
            switch(
                as,
                data.frame = data.frame(key = keys, value = values),
                tibble = tibble::tibble(key = keys, value = values)
            )
        }
    }, as)

    if (data_type[[1]] %in% c("json", "R")) # not NDJSON
        result <- result[[1]]

    result
}

#' @rdname flatten
#'
#' @title Flatten and find keys or values in JSON or NDJSON documents
#'
#' @description `j_flatten()` transforms a JSON document into a list
#'     where names are JSONpointer 'keys' and elements are the
#'     corresponding 'values' from the JSON document.
#'
#' @inheritParams j_query
#'
#' @param as character(1) describing the return type.  For
#'     `j_flatten()`, either "string" or "R". For other functions on
#'     this page, one of "R", "data.frame", or "tibble".
#'
#' @details Functions documented on this page expand `data` into all
#'     key / value pairs. This is not suitable for very large JSON
#'     documents.
#'
#' @return
#'
#' `j_flatten(as = "string")` (default) returns a JSON string
#' representation of the flattened document, i.e., an object with keys
#' the JSONpointer paths and values the values at the corresponding
#' path in the original document.
#'
#' `j_flatten(as = "R")` returns a named list, where `names()` are the
#' JSONpointer paths to each element in the JSON document and list
#' elements are the corresponding values.
#'
#' @examples
#' json <- '{
#'     "discards": {
#'         "1000": "Record does not exist",
#'         "1004": "Queue limit exceeded",
#'         "1010": "Discarding timed-out partial msg"
#'     },
#'     "warnings": {
#'         "0": "Phone number missing country code",
#'         "1": "State code missing",
#'         "2": "Zip code missing"
#'     }
#' }'
#'
#' j_flatten(json) |>
#'     str()
#'
#' @export
j_flatten <-
    function(
        data, object_names = "asis", as = "string", ...,
        n_records = Inf, verbose = FALSE, data_type = j_data_type(data)
    )
{
    stopifnot(.is_scalar_character(as), as %in% c("string", "R"))
    result <- .j_flatten(
        data, object_names, as, ...,
        n_records = n_records, verbose = verbose, data_type = data_type
    )
    if (data_type[[1]] %in% c("json", "R"))
        result <- result[[1]]

    result
}

#' @rdname flatten
#'
#' @description `j_find_values()` finds paths to exactly matching
#'     values.
#'
#' @param values vector of one or more values to be matched exactly to
#'     values in the JSON document.
#'
#' @return `j_find_values()` and `j_find_values_grep()` return a list
#'     with names as JSONpointer paths and list elements the matching
#'     values, or a `data.frame` or `tibble` with columns `path` and
#'     `value`. Values are coerced to a common type when `as` is
#'     `data.frame` or `tibble`.
#'
#' @examples
#' j_find_values(json, "Zip code missing", as = "tibble")
#' j_find_values(
#'     json,
#'     c("Queue limit exceeded", "Zip code missing"),
#'     as = "tibble"
#' )
#'
#' @export
j_find_values <-
    function(
        data, values, object_names = "asis", as = "R", ...,
        n_records = Inf, verbose = FALSE, data_type = j_data_type(data)
    )
{
    stopifnot(
        .is_scalar_character(as), as %in% c("R", "data.frame", "tibble")
    )

    result <- .j_flatten(
        data, object_names, "R", ...,
        n_records = n_records, verbose = verbose, data_type = data_type
    )
    flattened <- lapply(result, function(json_record) {
        Filter(\(x) x %in% values, json_record)
    })

    .j_find_format(flattened, as, data_type)
}

#' @rdname flatten
#'
#' @description `j_find_values_grep()` finds paths to values matching
#'     a regular expression.
#'
#' @param pattern character(1) regular expression to match values or
#'     keys.
#'
#' @param grep_args list() additional arguments passed to `grepl()`
#'     when searching on values or paths.
#'
#' @examples
#' j_find_values_grep(json, "missing", as = "tibble")
#'
#' @export
j_find_values_grep <-
    function(
        data, pattern, object_names = "asis", as = "R", ...,
        n_records = Inf, verbose = FALSE, data_type = j_data_type(data),
        grep_args = list()
    )
{
    stopifnot(
        .is_scalar_character(pattern),
        .is_scalar_character(as), as %in% c("R", "data.frame", "tibble")
        ## FIXME: validate grep_args
    )

    result <- .j_flatten(
        data, object_names, "R", ...,
        n_records = n_records, verbose = verbose, data_type = data_type
    )
    flattened <- lapply(result, function(json_record, grep_args) {
        values <- unlist(json_record, use.names = FALSE)
        idx <- .j_find_grepl(pattern, values, grep_args)
        json_record[idx]
    }, grep_args)

    .j_find_format(flattened, as, data_type)
}

#' @rdname flatten
#'
#' @description `j_find_keys()` finds paths to exactly matching keys.
#'
#' @param keys character() vector of one or more keys to be matched
#'     exactly to path elements.
#'
#' @details For `j_find_keys()`, the `key` must exactly match one or
#'     more consecutive keys in the JSONpointer path returned by
#'     `j_flatten()`.
#'
#' @return `j_find_keys()` and `j_find_keys_grep()` returns a list,
#'     data.frame, or tibble similar to `j_find_values()` and
#'     `j_find_values_grep()`.
#'
#' @examples
#' j_find_keys(json, "discards", as = "tibble")
#' j_find_keys(json, "1", as = "tibble")
#' j_find_keys(json, c("discards", "warnings"), as = "tibble")
#'
#' @export
j_find_keys <-
    function(
        data, keys, object_names = "asis", as = "R", ...,
        n_records = Inf, verbose = FALSE, data_type = j_data_type(data)
    )
{
    stopifnot(
        is.character(keys), !anyNA(keys),
        .is_scalar_character(as), as %in% c("R", "data.frame", "tibble")
    )

    result <- .j_flatten(
        data, object_names, "R", ...,
        n_records = n_records, verbose = verbose, data_type = data_type
    )
    flattened <- lapply(result, function(json_record) {
        keys0 <- names(json_record)
        keys1 <- strsplit(keys0, "/")
        idx1 <- unlist(keys1) %in% keys
        idx <- unique(rep(seq_along(keys1), lengths(keys1))[idx1])
        json_record[idx]
    })

    .j_find_format(flattened, as, data_type)
}

#' @rdname flatten
#'
#' @description `j_find_keys_grep()` finds paths to keys matching a
#'     regular expression.
#'
#' @details For `j_find_keys_grep()`, the `key` can define a pattern
#'     that spans across JSONpointer path elements.
#'
#' @examples
#' j_find_keys_grep(json, "discard", as = "tibble")
#' j_find_keys_grep(json, "1", as = "tibble")
#' j_find_keys_grep(json, "car.*/101", as = "tibble")
#'
#' @export
j_find_keys_grep <-
    function(
        data, pattern, object_names = "asis", as = "R", ...,
        n_records = Inf, verbose = FALSE, data_type = j_data_type(data),
        grep_args = list()
    )
{
    stopifnot(
        .is_scalar_character(pattern),
        .is_scalar_character(as), as %in% c("R", "data.frame", "tibble")
    )

    result <- .j_flatten(
        data, object_names, "R", ...,
        n_records = n_records, verbose = verbose, data_type = data_type
    )
    flattened <- lapply(result, function(json_record, grep_args) {
        idx <- .j_find_grepl(pattern, names(json_record), grep_args)
        json_record[idx]
    }, grep_args)

    .j_find_format(flattened, as, data_type)
}

#' @rdname flatten
#'
#' @name flatten_NDJSON
#'
#' @description For NDJSON documents, the result is either a character
#'     vector (for `as = "string"`) or list of *R* objects, one
#'     element for each NDJSON record.
#'
#' @return For NDJSON documents, the result is a vector paralleling
#'     the NDJSON document, with `j_flatten()` applied to each element
#'     of the NDJSON document.
#'
#' @examples
#' ## NDJSON
#'
#' ndjson_file <-
#'     system.file(package = "rjsoncons", "extdata", "example.ndjson")
#' j_flatten(ndjson_file) |>
#'     noquote()
#' j_find_values_grep(ndjson_file, "e") |>
#'     str()
NULL
