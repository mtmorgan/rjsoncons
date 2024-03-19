#' @rdname flatten
#'
#' @title Flatten and find keys or values
#'
#' @description `j_flatten()` transforms a JSON document into a list
#'     where names are JSONpointer 'keys' and elements are the
#'     corresponding 'values' from the JSON document.
#'
#' @inheritParams j_query
#'
#' @param as character(1) describing the return type.  For
#'     `j_flatten()`, either "string" or "R". For other functions on
#'     this page, one of "list", "data.frame", or "tibble".
#'
#' @details
#'
#' Functions documented on this page expand `data` into all key /
#' value pairs. This is not suitable for very large JSON documents.
#'
#' @return `j_flatten()` returns a named list, where `names()` are the
#'     JSONpointer paths to each element in the JSON document and list
#'     elements are the corresponding values.
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
        n_records = Inf, verbose = FALSE,
        data_type = j_data_type(data)
    )
{
    ## initialize constants to enable code re-use
    path <- ""
    path_type <- j_path_type(path)

    ## validity
    .j_valid(data_type, object_names, path, path_type, n_records, verbose)
    stopifnot(.is_scalar_character(as), as %in% c("string", "R"))

    data <- .as_json_string(data, data_type, ...)
    result <- do_cpp(
        cpp_j_flatten, cpp_j_flatten_con,
        data, data_type, object_names, as, path, path_type,
        n_records = n_records, verbose = verbose
    )

    if (data_type[[1]] %in% c("json", "R"))
        result <- result[[1]]

    result
}

j_find_format <-
    function(flattened, as)
{
    if (identical(as, "list")) {
        flattened
    } else {
        keys <- names(flattened)
        values <- unlist(flattened, use.names = FALSE)
        switch(
            as,
            data.frame = data.frame(key = keys, value = values),
            tibble = tibble::tibble(key = keys, value = values)
        )
    }
}

#' @rdname flatten
#'
#' @description `j_find_values()` finds paths to exactly matching
#'     values.
#'
#' @param values vector of one or more values, all of the same type
#'     (e.g., double, integer, character).
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
        data, values, object_names = "asis", as = "list",
        data_type = j_data_type(data)
    )
{
    types <- unique(vapply(values, typeof, character(1)))
    stopifnot(
        length(types) == 1L,
        .is_scalar_character(as), as %in% c("list", "data.frame", "tibble")
    )

    flattened0 <- j_flatten(data, object_names, "R")
    flattened <- Filter(\(x) x %in% values, flattened0)

    j_find_format(flattened, as)
}

#' @rdname flatten
#'
#' @description `j_find_values_grep()` finds paths to values matching
#'     a regular expression.
#'
#' @param pattern character(1) regular expression to match values or
#'     keys.
#'
#' @param ... for `j_find_values_grep()` and `j_find_keys_grep()`,
#'     additional arguments passed to `grepl()`.
#'
#' @examples
#' j_find_values_grep(json, "missing", as = "tibble")
#'
#' @export
j_find_values_grep <-
    function(
        data, pattern, ..., object_names = "asis", as = "list",
        data_type = j_data_type(data)
    )
{
    stopifnot(
        .is_scalar_character(pattern),
        .is_scalar_character(as), as %in% c("list", "data.frame", "tibble")
    )

    flattened <- j_flatten(data, object_names, "R")
    values <- unlist(flattened, use.names = FALSE)
    idx <- grepl(pattern, values, ...)

    j_find_format(flattened[idx], as)
}

#' @rdname flatten
#'
#' @description `j_find_keys()` finds paths to exactly matching keys.
#'
#' @param keys character() vector of one or more keys to be matched
#'     exactly to path elements.
#'
#' @details
#'
#' For `j_find_keys()`, the `key` must exactly match one or more
#' consecutive keys in the JSONpointer path returned by `j_flatten()`.
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
        data, keys, object_names = "asis", as = "list",
        data_type = j_data_type(data)
    )
{
    stopifnot(
        is.character(keys), !anyNA(keys),
        .is_scalar_character(as), as %in% c("list", "data.frame", "tibble")
    )

    flattened <- j_flatten(data, object_names, "R")
    keys0 <- names(flattened)
    keys1 <- strsplit(keys0, "/")
    idx1 <- unlist(keys1) %in% keys
    idx <- unique(rep(seq_along(keys1), lengths(keys1))[idx1])

    j_find_format(flattened[idx], as)
}

#' @rdname flatten
#'
#' @description `j_find_keys_grep()` finds paths to keys matching a
#'     regular expression.
#'
#' @details
#'
#' For `j_find_keys_grep()`, the `key` can define a pattern that spans
#' across JSONpointer path elements.
#'
#' @examples
#' j_find_keys_grep(json, "discard", as = "tibble")
#' j_find_keys_grep(json, "1", as = "tibble")
#' j_find_keys_grep(json, "car.*/101", as = "tibble")
#'
#' @export
j_find_keys_grep <-
    function(
        data, pattern, ..., object_names = "asis", as = "list",
        data_type = j_data_type(data)
    )
{
    stopifnot(
        .is_scalar_character(pattern),
        .is_scalar_character(as), as %in% c("list", "data.frame", "tibble")
    )

    flattened <- j_flatten(data, object_names, "R")
    idx <- grepl(pattern, names(flattened), ...)

    j_find_format(flattened[idx], as)
}
