#' @rdname as_r
#'
#' @title Parse JSON to R
#'
#' @description `as_r()` transforms a JSON string to an *R* object.
#'
#' @inheritParams j_query
#'
#' @param data a character(1) JSON string or (unusually) an `R` object.
#'
#' @param ... passed to `jsonlite::toJSON()` in the unusual
#'     circumstance that `data` is an `R` object.
#'
#' @details
#'
#' The `as = "R"` argument to `j_query()`, `j_pivot()`, etc., and the
#' `as_r()` function transform a JSON string representation to an *R*
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
    function(data, object_names = "asis", ...)
{
    stopifnot(
        .is_scalar_character(object_names)
    )

    data <- .as_json_string(data, ..., data_type = "json")
    cpp_as_r(data, object_names)
}
