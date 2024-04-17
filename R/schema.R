do_j_schema <-
    function(fun, data, schema, ..., data_type, schema_type)
{
    if (.is_j_data_type_connection(data_type)) {
        data <- .as_unopened_connection(data, data_type)
        open(data, "rb")
        on.exit(close(data))
    }
    if (.is_j_data_type_connection(schema_type)) {
        schema <- .as_unopened_connection(schema, schema_type)
        open(schema, "rb")
        on.exit(close(schema))
    }
    fun(data, schema, ...)
}

#' @rdname schema
#'
#' @title Validate JSON documents against JSON Schema
#'
#' @description `j_schema_is_vaild()` uses JSON Schema
#'     <https://json-schema.org/> to validate JSON 'data' according to
#'     'schema'.
#'
#' @param data JSON character vector, file, or URL defining document
#'     to be validated. NDJSON data and schema are not supported.
#'
#' @param schema JSON character vector, file, or URL defining the
#'     schema against which `data` will be validated.
#'
#' @param ... passed to `jsonlite::toJSON` when `data` is not
#'     character-valued.
#'
#' @param data_type character(1) type of `data`; one of `"json"` or a
#'     value returned by `j_data_type()`; schema validation does not
#'     support `"ndjson"` data.
#'
#' @param schema_type character(1) type of `schema`; see `data_type`.
#'
#' @examples
#' ## Allowable `data_type=` and `schema_type` -- excludes 'ndjson'
#' j_data_type() |>
#'     Filter(\(type) !"ndjson" %in% type, x = _) |>
#'     str()
#' ## compare JSON patch to specification. 'op' key should have value
#' ## 'add'; 'paths' key should be key 'path'
#' ## schema <- "https://json.schemastore.org/json-patch.json"
#' schema <- system.file(package = "rjsoncons", "extdata", "json-patch.json")
#' op <- '[{
#'     "op": "adds", "paths": "/biscuits/1",
#'     "value": { "name": "Ginger Nut" }
#' }]'
#' j_schema_is_valid(op, schema)
#'
#' @export

j_schema_is_valid <-
    function(
        data, schema, ..., 
        data_type = j_data_type(data), schema_type = j_data_type(schema)
    )
{
    stopifnot(
        ## don't support ndjson (yet?)
        data_type[[1]] %in% c("json", "R"),
        schema_type[[1]] %in% c("json", "R")
    )

    data <- .as_json_string(data, data_type, ...)
    schema <- .as_json_string(schema, schema_type, ...)
    do_j_schema(
        cpp_j_schema_is_valid, data, schema,
        data_type = data_type, schema_type = schema_type
    )
}

#' @rdname schema
#'
#' @description `j_schema_validate()` returns a JSON or *R* object,
#'     data.frame, or tibble, describing how `data` does not conform
#'     to `schema`. See the "Using 'jsoncons' in R" vignette for help
#'     interpreting validation results.
#'
#' @param as for `j_schema_validate()`, one of `"string"`, `"R"`,
#'     `"data.frame"`, `"tibble"`, or `"details"`, to determine the
#'     representation of the return value.
#'
#' @examples
#' j_schema_validate(op, schema, as = "details")
#'
#' @export
j_schema_validate <-
    function(
        data, schema, as = "string", ...,
        data_type = j_data_type(data), schema_type = j_data_type(schema)
    )
{
    stopifnot(
        ## don't support ndjson (yet?)
        data_type[[1]] %in% c("json", "R"),
        schema_type[[1]] %in% c("json", "R"),
        as %in% c("string", "R", "data.frame", "tibble", "details")
    )

    data <- .as_json_string(data, data_type, ...)
    schema <- .as_json_string(schema, schema_type, ...)
    as0 <- ifelse(identical(as, "R"), "R", "string")
    result <- do_j_schema(
        cpp_j_schema_validate, data, schema, as = as0,
        data_type = data_type, schema_type = schema_type
    )

    switch(
        as,
        string = result,
        R = result,
        data.frame =,
        tibble = j_pivot(result, as = as),
        details = j_pivot(result, "[].details[]", as = "tibble")
    )
}
