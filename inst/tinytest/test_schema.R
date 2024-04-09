schema <- system.file(package = "rjsoncons", "extdata", "json-patch.json")

op <- '[{"op": "add", "path": "/biscuits/1", "value": { "name": "Ginger Nut" }}]'
expect_true(j_schema_is_valid(op, schema))
expect_identical(j_schema_validate(op, schema), "[]")
expect_identical(j_schema_validate(op, schema, as = "R"), list())
expect_identical(j_schema_validate(op, schema, as = "data.frame"), data.frame())
expect_identical(
    j_schema_validate(op, schema, as = "tibble"),
    tibble::tibble()
)
expect_identical(
    j_schema_validate(op, schema, as = "details"),
    tibble::tibble()
)

## e.g., missing 'op'
op <- '[{"path": "/biscuits/1", "value": { "name": "Ginger Nut" }}]'
expect_false(j_schema_is_valid(op, schema))
expect_identical(
    j_schema_validate(op, schema) |> j_query("[].error"),
    '["No schema matched, but exactly one of them is required to match"]'
)
expect_identical(
    j_schema_validate(op, schema) |>
    j_query("length([].details[])", as = "R"),
    6L
)
expect_identical(
    j_schema_validate(op, schema, as = "tibble") |> dim(),
    c(1L, 6L)
)
expect_identical(
    j_schema_validate(op, schema, as = "details") |> dim(),
    c(6L, 5L)
)

## other schema inputs
expect_identical(
    j_schema_validate(op, schema),
    j_schema_validate(op, readLines(schema))
)
expect_identical(
    j_schema_validate(op, schema),
    j_schema_validate(op, paste(readLines(schema), collapse = "\n"))
)

## do not support ndjson
expect_error(j_schema_is_valid(op, schema, data_type = "ndjson"))
expect_error(j_schema_validate(op, schema, data_type = "ndjson"))
