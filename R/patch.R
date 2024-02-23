.is_j_patch_type <-
    function(x)
{
    identical(x[[1]], "json")
}
.j_patch_data_from_connection <-
    function(data, data_type)
{
    con <- .as_unopened_connection(data, data_type)
    open(con, "rb")
    on.exit(close(con))
    lines <- readLines(con, warn = FALSE)
    paste(trimws(lines), collapse = "\n")
}

#' @rdname patch
#'
#' @title Patch or compute the difference between two JSON documents
#'
#' @description `j_patch_apply()` uses JSON Patch
#'     <https://jsonpatch.com> to transform JSON 'data' according the
#'     rules in JSON 'patch'.
#'
#' @param data JSON character vector, file, URL, or an *R* object to
#'     be converted to JSON using `jsonline::fromJSON(data, ...)`.
#'
#' @param patch JSON 'patch' as character vector, file, URL, or *R*
#'     object.
#'
#' @param as character(1) return type; `"string"` returns a JSON
#'     string, `"R"` returns an *R* object using the rules in
#'     `as_r()`.
#'
#' @return `j_patch_apply()` returns a JSON string or *R* object
#'     representing 'data' patched according to 'patch'.
#'
#' @examples
#' data_file <- system.file(package = "rjsoncons", "extdata", "patch_data.json")
#'
#' ## add a biscuit
#' patch <- '[
#'     {"op": "add", "path": "/biscuits/1", "value": {"name": "Ginger Nut" }}
#' ]'
#' j_patch_apply(data_file, patch, as = "R") |> str()
#'
#' ## add a biscuit and choose a favorite
#'patch <- '[
#'     {"op": "add", "path": "/biscuits/1", "value": {"name": "Ginger Nut" }},
#'     {"op": "copy", "from": "/biscuits/0", "path": "/best_biscuit"}
#' ]'
#' biscuits <- j_patch_apply(data_file, patch)
#' as_r(biscuits) |> str()
#'
#' @export
j_patch_apply <-
    function(data, patch, as = "string", ...)
{
    data_type <- j_data_type(data)
    patch_type <- j_data_type(patch)
    stopifnot(
        ## FIXME: support NDJSON
        .is_j_patch_type(data_type),
        .is_j_patch_type(patch_type),
        as %in% c("string", "R")
    )

    if (.is_j_data_type_connection(data_type)) {
        data <- .j_patch_data_from_connection(data, data_type)
        data_type <- data_type[[1]]
    }
    if (.is_j_data_type_connection(patch_type)) {
        data <- .j_patch_data_from_connection(patch, patch_type)
        data_type <- data_type[[1]]
    }

    data <- .as_json_string(data, data_type, ...)
    patch <- .as_json_string(patch, patch_type, ...)

    result <- do_cpp(
        cpp_j_patch_apply, NULL,
        data, data_type, patch, as,
        n_records = Inf, verbose = FALSE
    )

    result
}

#' @rdname patch
#'
#' @description `j_patch_from()` computes a JSON patch describing the
#'     difference between to JSON documents.
#'
#' @param data_x As for `data`.
#'
#' @param data_y As for `data`.
#'
#' @return `j_patch_from()` returns a JSON string or *R* object
#'     representing the difference between 'data_x' and 'data_y'.
#'
#' @examples
#' j_patch_from(biscuits, data_file, as = "R") |> str()
#'
#' @export
j_patch_from <-
    function(data_x, data_y, as = "string", ...)
{
    data_type_x <- j_data_type(data_x)
    data_type_y <- j_data_type(data_y)
    stopifnot(
        ## FIXME: support NDJSON
        .is_j_patch_type(data_type_x),
        .is_j_patch_type(data_type_y),
        as %in% c("string", "R")
    )

    if (.is_j_data_type_connection(data_type_x)) {
        data_x <- .j_patch_data_from_connection(data_x, data_type_x)
        data_type_x <- data_type_x[[1]]
    } else {
        data_x <- .as_json_string(data_x, data_type_x, ...)
    }
    if (.is_j_data_type_connection(data_type_y)) {
        data_y <- .j_patch_data_from_connection(data_y, data_type_y)
        data_type_y <- data_type_y[[1]]
    } else {
        data_y <- .as_json_string(data_y, data_type_y)
    }

    data_x <- .as_json_string(data_x, data_type_x, ...)
    data_y <- .as_json_string(data_y, data_type_y, ...)

    result <- do_cpp(
        cpp_j_patch_from, NULL,
        data_x, data_type_x, data_y, data_type_y,
        as, n_records = Inf, verbose = FALSE
    )

    result
}
