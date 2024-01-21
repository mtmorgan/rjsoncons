## j_data_type

.is_j_data_type <- rjsoncons:::.is_j_data_type

expect_identical(
    j_data_type(),
    list(
        "json", "ndjson",
        c("json", "file"), c("ndjson", "file"), 
        c("json", "url"), c("ndjson", "url"),
        "R"
    )
)
expect_identical(j_data_type(""), "R")
expect_identical(j_data_type('""'), "json")
expect_identical(j_data_type("null"), "json")
expect_identical(j_data_type('{"a": 1}'), "json")
expect_identical(j_data_type(c('[', ']')), "json")
expect_identical(j_data_type(c('[{"a": 1}', '{"a": 2}]')), "json")
expect_identical(j_data_type(c('{"a": 1}', '{"a": 2}')), "ndjson")
expect_identical(j_data_type(list(a = 1, b = 2)), "R")

fl <- system.file(package = "rjsoncons", "extdata", "example.json")
expect_identical(j_data_type(fl), c("json", "file"))
expect_identical(j_data_type(readLines(fl)), "json")
expect_true(.is_j_data_type(j_data_type(fl)))

fl <- system.file(package = "rjsoncons", "extdata", "example.ndjson")
expect_identical(j_data_type(fl), c("ndjson", "file"))
expect_identical(j_data_type(readLines(fl)), "ndjson")
expect_true(.is_j_data_type(j_data_type(fl)))

expect_error(j_data_type(c(' [', ']'))) # no leading ws in multi-line JSON

## j_path_type

expect_identical(j_path_type(), c("JSONpointer", "JSONpath", "JMESpath"))
expect_identical(j_path_type(""), "JSONpointer")
expect_identical(j_path_type("/locations/0/name"), "JSONpointer")
expect_identical(j_path_type("$.locations[0].name"), "JSONpath")
expect_identical(j_path_type("locations[0].name"), "JMESpath")
expect_identical(j_path_type("@"), "JMESpath")

expect_identical(j_path_type(" $.locations[0].name"), "JSONpath")

expect_error(j_path_type(character()))
expect_error(j_path_type(c("", "")))
expect_error(j_path_type(NA_character_))
