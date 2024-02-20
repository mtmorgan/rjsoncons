#' @rdname as_r
#'
#' @title Parse JSON or NDJSON to R
#'
#' @description `as_r()` transforms JSON or NDJSON to an *R* object.
#'
#' @inheritParams j_query
#'
#' @details
#'
#' The `as = "R"` argument to `j_query()`, `j_pivot()`, and the
#' `as_r()` function transform JSON or NDJSON to an *R* object. JSON
#' and NDJSON can be a character vector, file, or url, or an *R*
#' object (which is first translated to a JSON string). Main rules are:
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
#' json <- '{"b": 1, "a": ["c", "d"], "e": true, "f": [true], "g": {}}'
#' as_r(json) |> str()     # parsing complex objects
#' identical(              # JSON scalar and length 1 array identical in R
#'     as_r('{"a": 1}'), as_r('{"a": [1]}')
#' )
#'
#' @return `as_r()` returns an *R* object.
#'
#' @export
as_r <-
    function(
        data, object_names = "asis", ...,
        n_records = Inf, verbose = FALSE,
        data_type = j_data_type(data)
    )
{
    stopifnot(
        .is_scalar_character(object_names),
        object_names %in% c("asis", "sort"),
        .is_scalar_numeric(n_records),
        .is_scalar_logical(verbose),
        .is_j_data_type(data_type)
    )

    data <- .as_json_string(data, data_type, ...)
    result <- do_cpp(
        cpp_as_r, cpp_as_r_con,
        data, data_type, object_names,
        n_records = n_records, verbose = verbose
    )

    if (data_type[[1]] %in% c("json", "R"))
        result <- result[[1]]

    result
}
