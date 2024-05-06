J_PATCH_OP <- c("add", "remove", "replace", "copy", "move", "test")

.is_j_patch_type <-
    function(x)
{
    identical(x[[1]], "json") || identical(x[[1]], "R")
}
.j_patch_data_from_connection <-
    function(data, data_type)
{
    con <- .as_unopened_connection(data, data_type)
    open(con, "rb")
    on.exit(close(con))
    lines <- readLines(con, warn = FALSE)
    paste0(trimws(lines), collapse = "\n")
}

.j_patch_patch_validate <-
    function(patch)
{
    ## FIXME: use j_schema_validate() when available
    bad_op <- character()
    if (!j_query(patch, "type(@)") %in% "array") {
        stop("'patch' must be a JSON array")
    }
    op <- j_query(patch, "[].op", as = "R")
    bad_op <- setdiff(op, J_PATCH_OP)
    if (length(bad_op)) {
        stop(
            "'patch' malformed:\n",
            "  op: ", toString(bad_op), "\n",
            "  not in: ", toString(J_PATCH_OP), "\n",
            call. = FALSE
        )
    }

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
#' @param patch JSON 'patch' as character vector, file, URL, *R*
#'     object, or the result of `j_patch_op()`.
#'
#' @param as character(1) return type; `"string"` returns a JSON
#'     string, `"R"` returns an *R* object using the rules in
#'     `as_r()`.
#'
#' @param ...
#'
#' For `j_patch_apply()` and `j_patch_diff()`, arguments passed to
#' `jsonlite::toJSON` when `data`, `patch`, `data_x`, and / or
#' `data_y` is an _R_ object.  It is appropriate to add the
#' `jsonlite::toJSON()` argument `auto_unbox = TRUE` when `patch` is
#' an *R* object and any 'value' fields are JSON scalars; for more
#' complicated scenarios 'value' fields should be marked with
#' `jsonlite::unbox()` before being passed to `j_patch_*()`.
#'
#' For `j_patch_op()` the `...` are additional arguments to the patch
#' operation, e.g., `path = ', `value = '.
#'
#' @return `j_patch_apply()` returns a JSON string or *R* object
#'     representing 'data' patched according to 'patch'.
#'
#' @details
#'
#' For `j_patch_apply()`, 'patch' is a JSON array of objects. Each
#' object describes how the patch is to be applied. Simple examples
#' are available at <https://jsonpatch.com>, with verbs 'add',
#' 'remove', 'replace', 'copy' and 'test'. The 'path' element of each
#' operation is a JSON pointer; remember that JSON arrays are 0-based.
#'
#' 
#' - `add` -- add elements to an existing document.
#'     ```
#'     {"op": "add", "path": "/biscuits/1", "value": {"name": "Ginger Nut"}}
#'     ```
#' - `remove` -- remove elements from a document.
#'     ```
#'     {"op": "remove", "path": "/biscuits/0"}
#'     ```
#' - `replace` -- replace one element with another
#'     ```
#'     {
#'         "op": "replace", "path": "/biscuits/0/name",
#'         "value": "Chocolate Digestive"
#'     }
#'     ```
#' - `copy` -- copy a path to another location.
#'     ```
#'     {"op": "copy", "path": "/best_biscuit", "from": "/biscuits/0"}
#'     ```
#' - `move` -- move a path to another location.
#'     ```
#'     {"op": "move", "path": "/cookies", "from": "/biscuits"}
#'     ```
#' - `test` -- test for the existence of a path; if the path does not
#'   exist, do not apply any of the patch.
#'     ```
#'     {"op": "test", "path": "/best_biscuit/name", "value": "Choco Leibniz"}
#'     ```
#' 
#' The examples below illustrate a patch with one (a JSON array with a
#' single object) or several (a JSON array with several arguments)
#' operations. `j_patch_apply()` fits naturally into a pipeline
#' composed with `|>` to transform JSON between representations.
#'
#' @examples
#' data_file <-
#'     system.file(package = "rjsoncons", "extdata", "patch_data.json")
#'
#' ## add a biscuit
#' patch <- '[
#'     {"op": "add", "path": "/biscuits/1", "value": {"name": "Ginger Nut"}}
#' ]'
#' j_patch_apply(data_file, patch, as = "R") |> str()
#'
#' ## add a biscuit and choose a favorite
#'patch <- '[
#'     {"op": "add", "path": "/biscuits/1", "value": {"name": "Ginger Nut"}},
#'     {"op": "copy", "path": "/best_biscuit", "from": "/biscuits/2"}
#' ]'
#' biscuits <- j_patch_apply(data_file, patch)
#' as_r(biscuits) |> str()
#'
#' @export
j_patch_apply <-
    function(data, patch, as = "string", ...)
{
    data_type <- j_data_type(data)
    if (inherits(patch, "j_patch_op")) {
        ## formats as JSON array-of-objects
        patch <- as.character(patch)
    }
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
    .j_patch_patch_validate(patch)

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
#'     difference between two JSON documents.
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
        data_y <- .as_json_string(data_y, data_type_y, ...)
    }

    result <- do_cpp(
        cpp_j_patch_from, NULL,
        data_x, data_type_x, data_y, data_type_y,
        as, n_records = Inf, verbose = FALSE
    )

    result
}

#' @rdname patch
#'
#' @description `j_patch_op()` translates *R* arguments to the JSON
#'     representation of a patch, validating and 'unboxing' arguments
#'     as necessary.
#'
#' @param op A patch operation (`"add"`, `"remove"`, `"replace"`,
#'     `"copy"`, `"move"`, `"test"`), or when 'piping' an object
#'     created by `j_patch_op()`.
#'
#' @param path A character(1) JSONPointer path to the location being patched.
#'
#' @param from A character(1) JSONPointer path to the location an
#'     object will be copied or moved from.
#'
#' @param value An *R* object to be translated into JSON and used during
#'     add, replace, or test.
#'
#' @details
#'
#' The `j_patch_op()` function takes care to ensure that `op`, `path`,
#' and `from` arguments are 'unboxed' (represented as JSON scalars
#' rather than arrays). The user must ensure that `value` is
#' represented correctly by applying `jsonlite::unbox()` to individual
#' elements or adding `auto_unbox = TRUE` to `...`. Examples
#' illustrate these different scenarios.
#'
#' @return `j_patch_op()` returns a character vector subclass that can
#'     be used in `j_patch_apply()`.
#'
#' @examples
#' if (requireNamespace("jsonlite", quietly = TRUE)) {
#' ## helper for constructing patch operations from R objects
#' j_patch_op(
#'     "add", path = "/biscuits/1", value = list(name = "Ginger Nut"),
#'     ## 'Ginger Nut' is a JSON scalar, so auto-unbox the 'value' argument
#'     auto_unbox = TRUE
#' )
#' j_patch_op("remove", "/biscuits/0")
#' j_patch_op(
#'     "replace", "/biscuits/0/name",
#'     ## also possible to unbox arguments explicitly
#'     value = jsonlite::unbox("Chocolate Digestive")
#' )
#' j_patch_op("copy", "/best_biscuit", from = "/biscuits/0")
#' j_patch_op("move", "/cookies", from = "/biscuits")
#' j_patch_op(
#'     "test", "/best_biscuit/name", value = "Choco Leibniz",
#'     auto_unbox = TRUE
#' )
#'
#' ## several operations
#' value <- list(name = jsonlite::unbox("Ginger Nut"))
#' ops <- c(
#'     j_patch_op("add", "/biscuits/1", value = value),
#'     j_patch_op("copy", path = "/best_biscuit", from = "/biscuits/0")
#' )
#' ops
#'
#' ops <-
#'     j_patch_op("add", "/biscuits/1", value = value) |>
#'     j_patch_op("copy", path = "/best_biscuit", from = "/biscuits/0")
#' ops
#' }
#' @export
j_patch_op <-
    function(op, path, ...)
{
    UseMethod("j_patch_op")
}

#' @rdname patch
#'
#' @export
j_patch_op.default <-
    function(op, path, ..., from = NULL, value = NULL)
{
    op <- match.arg(op, J_PATCH_OP)
    stopifnot(
        ## all ops require 'path'
        !missing(path),
        identical(j_path_type(path), "JSONpointer")
    )
    patch <- list(op = jsonlite::unbox(op), path = jsonlite::unbox(path))

    ## 'remove' requires only 'op' and 'path'; other ops require...
    switch(op, add =, replace =, test = {
        stopifnot(!is.null(value))
        patch[["value"]] <- value # user-specified 'auto_unbox' in '...'
    }, copy =, move = {
        stopifnot(.is_scalar_character(from))
        patch[["from"]] <- jsonlite::unbox(from)
    })

    patch <- j_query(patch, ...)
    structure(c("[", patch, "]"), class = "j_patch_op")
}

#' @rdname patch
#'
#' @importFrom utils head tail
#'
#' @export
j_patch_op.j_patch_op <-
    function(op, ...)
{
    patch <- c(head(op, -1), ",", tail(j_patch_op(...), -1))
    structure(patch, class = "j_patch_op")
}

#' @rdname patch
#'
#' @param recursive Ignored.
#'
#' @export
c.j_patch_op <-
    function(..., recursive = FALSE)
{
    args <- list(...)
    args[-1] <- lapply(args[-1], tail, -1L)
    args[-length(args)] <- lapply(args[-length(args)], \(x) {
        x[length(x)] = ","
        x
    })
    args <- lapply(args, unclass)
    result <- do.call("c", args)
    structure(result, class = "j_patch_op")
}

#' @rdname patch
#'
#' @param x An object produced by `j_patch_op()`.
#'
#' @export
print.j_patch_op <-
    function(x, ...)
{
    width <- as.integer(getOption("width"))
    indent <- 2L
    stopifnot(.is_scalar_numeric(width))
    patch <- paste(x, collapse = "\n")
    cat(cpp_j_patch_print(patch, indent, width), "\n")
}
