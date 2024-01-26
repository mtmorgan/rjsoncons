.is_j_data_type <-
    function(x)
{
    if (length(x) == 1L) {
        .is_scalar_character(x) && (x %in% j_data_type())
    } else if (length(x) == 2L) {
        is.character(x) && !anyNA(x) && all(nzchar(x)) &&
            x[[1]] %in% c("json", "ndjson") &&
            x[[2]] %in% c("file", "url")
    } else {
        ## length 0 or > 2
        FALSE
    }
}

.is_j_data_type_file <-
    function(x)
{
    .is_j_data_type_connection(x) && (x[[2]] %in% "file")
}

.is_j_data_type_url <-
    function(x)
{
    .is_j_data_type_connection(x) && (x[[2]] %in% "url")
}

.is_j_data_type_connection <-
    function(x)
{
    .is_j_data_type(x) && length(x) == 2L && (x[[2]] %in% c("file", "url"))
}

#' @rdname j_data_type
#'
#' @title Detect JSON / NDJSON data and path types
#'
#' @description `j_data_type()` uses simple rules to determine whether
#'     'data' is JSON, NDJSON, file, url, or R.
#'
#' @inheritParams j_query
#'
#' @details
#'
#' `j_data_type()` without any arguments reports possible return
#' values: `"json"`, `"ndjson"`, `"file"`, `"url"`, `"R"`.  When
#' provided an argument, `j_data_type()` infers (but does not
#' validate) the type of `data` based on the following rules:
#'
#' - For a scalar (length 1) character `data`, either `"url"`
#'   (matching regular expression `"^https?://"`, `"file"`
#'   (`file.exists(data)` returns `TRUE`), or `"json"`. When `"file"`
#'   or `"url"` is inferred, the return value is a length 2 vector,
#'   with the first element the inferred type of data (`"json"` or
#'   `"ndjson"`) obtained from the first 2 lines of the file.
#' - For character data with `length(data) > 1`, `"ndjson"` if all
#'   elements start a square bracket or curly brace, consistently
#'   (i.e., agreeing with the start of the first record), otherwise
#'   `"json"`.
#' - `"R"` for all non-character data.
#'
#' @examples
#' j_data_type()                            # available types
#' j_data_type("")                          # json
#' j_data_type('{"a": 1}')                  # json
#' j_data_type(c('[{"a": 1}', '{"a": 2}]')) # json
#' j_data_type(c('{"a": 1}', '{"a": 2}'))   # ndjson
#' j_data_type(list(a = 1, b = 2))          # R
#' fl <- system.file(package = "rjsoncons", "extdata", "example.json")
#' j_data_type(fl)                          # c('json', 'file')
#' j_data_type(readLines(fl))               # json
#'
#' @export
j_data_type <-
    function(data)
{
    if (missing(data)) {
        ## possible values
        return(list(
            "json", "ndjson",
            c("json", "file"), c("ndjson", "file"),
            c("json", "url"), c("ndjson", "url"),
            "R"
        ))
    }

    if (is.character(data)) {
        stopifnot(
            !anyNA(data),
            length(data) > 0L
        )

        if (length(data) == 1L) {
            ## url or file path or json
            if (length(grep("^https?://", data))) {
                c(j_data_type(readLines(data, 2L)), "url")
            } else if (file.exists(data)) {
                c(j_data_type(readLines(data, 2L)), "file")
            } else if (.is_scalar_character(data) && !inherits(data, "AsIs")) {
                "json"
            } else {
                "R"
            }
        } else if (substr(data[1], 1, 1) %in% c("{", "[")) {
            if (all(substr(data, 1, 1) %in% substr(data[1], 1, 1))) {
                "ndjson"
            } else {
                "json"
            }
        } else {
            stop("`j_data_type()` could not infer `data` type")
        }
    } else {
        "R"
    }
}

#' @rdname j_data_type
#'
#' @description `j_path_type()` uses simple rules to identify
#'     whether `path` is a JSONpointer, JSONpath, or JMESpath
#'     expression.
#'
#' @details
#'
#' `j_path_type()` without any argument reports possible values:
#' `"JSONpointer"`, `"JSONpath"`, or `"JMESpath"`. When provided an
#' argument, `j_path_type()` infers the type of `path` using a simple
#' but incomplete classification:
#'
#' - `"JSONpointer"` is inferred if the the path is `""` or starts with `"/"`.
#' - `"JSONpath"` expressions start with `"$"`.
#' - `"JMESpath"` expressions satisfy neither the `JSONpointer` nor
#'   `JSONpath` criteria.
#'
#' Because of these rules, the valid JSONpointer path `"@"` is
#' interpreted as JMESpath; use `jsonpointer()` if JSONpointer
#' behavior is required.
#'
#' @examples
#' j_path_type()                            # available types
#' j_path_type("")                          # JSONpointer
#' j_path_type("/locations/0/name")         # JSONpointer
#' j_path_type("$.locations[0].name")       # JSONpath
#' j_path_type("locations[0].name")         # JMESpath
#'
#' @export
j_path_type <-
    function(path)
{
    if (missing(path)) {
        return(c("JSONpointer", "JSONpath", "JMESpath"))
    }

    stopifnot(
        .is_scalar_character(path, z.ok = TRUE)
    )

    path <- trimws(path)
    if (nzchar(path)) {
        switch(
            substring(path, 1, 1),
            "/" = "JSONpointer",
            "$" = "JSONpath",
            "JMESpath"
        )
    } else {
        "JSONpointer"
    }
}
