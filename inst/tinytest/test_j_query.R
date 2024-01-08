json <- '{
  "locations": [
    {"name": "Seattle", "state": "WA"},
    {"name": "New York", "state": "NY"},
    {"name": "Bellevue", "state": "WA"},
    {"name": "Olympia", "state": "WA"}
  ]
}'

json_pretty <- # remove whitespace
    '{"locations":[{"name":"Seattle","state":"WA"},{"name":"New York","state":"NY"},{"name":"Bellevue","state":"WA"},{"name":"Olympia","state":"WA"}]}'

## j_query

expect_identical(j_query(""), '[""]') # JSONpointer
expect_identical(j_query('""'), '')
expect_identical(j_query('[]'), '[]')
expect_identical(j_query('{}'), '{}')
expect_identical(j_query(json), json_pretty)

expect_identical(
    j_query(json, "/locations/0/name"),   # JSONpointer
    "Seattle"
)
expect_identical(
    j_query(json, "$.locations[*].name"), # JSONpath
    '["Seattle","New York","Bellevue","Olympia"]'
    )
expect_identical(
    j_query(json, "locations[].name"),    # JMESpath
    '["Seattle","New York","Bellevue","Olympia"]'
)

expect_identical(
    j_query(json, "/locations/0", as = "R"),        # JSONpointer
    list(name = "Seattle", state = "WA")
)
expect_identical(
    j_query(json, "$.locations[*].name", as = "R"), # JSONpath
    c("Seattle", "New York", "Bellevue", "Olympia")
)
expect_identical(
    j_query(json, "locations[].name", as = "R"),   # JMESpath
    c("Seattle", "New York", "Bellevue", "Olympia")
)

## j_pivot

expected_r <- list(
    name = c("Seattle", "New York", "Bellevue", "Olympia"),
    state = c("WA", "NY", "WA", "WA")
)

expected_df <- structure(
    expected_r, class = "data.frame", row.names = c(NA, -4L)
)

expect_identical(j_pivot(json, "/locations", as = "R"), expected_r)
expect_identical(j_pivot(json, "/locations", as = "data.frame"), expected_df)

expect_identical(j_pivot(json, "$.locations[*]", as = "R"), expected_r)
expect_identical(j_pivot(json, "$.locations[*]", as = "data.frame"), expected_df)

expect_identical(j_pivot(json, "locations[]", as = "R"), expected_r)
expect_identical(j_pivot(json, "locations[]", as = "data.frame"), expected_df)

expect_error(j_pivot(json, "/locations/0"))
expect_error(j_pivot(json, "/locations[0].name"))

## j_data_type

expect_identical(j_data_type(), c("json", "ndjson", "file", "url", "R"))
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
