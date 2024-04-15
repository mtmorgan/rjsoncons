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

json_multiline <- strsplit(json, "\n")[[1]]

json_file <- system.file(package = "rjsoncons", "extdata", "example.json")

ndjson <- c(
    '{"name": "Seattle", "state": "WA"}',
    '{"name": "New York", "state": "NY"}',
    '{"name": "Bellevue", "state": "WA"}',
    '{"name": "Olympia", "state": "WA"}'
)

ndjson_file <- system.file(package = "rjsoncons", "extdata", "example.ndjson")

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

expect_identical(
    j_query(json_multiline, "locations[].name", as = "R"),
    c("Seattle", "New York", "Bellevue", "Olympia")
)

expect_identical(
    j_query(json_file, "locations[].name", as = "R"),
    c("Seattle", "New York", "Bellevue", "Olympia")
)

# ndjson

expect_identical(
    j_query(ndjson, "name"),
    c("Seattle", "New York", "Bellevue", "Olympia")
)
expect_identical(
    j_query(ndjson, "{name: name}", as = "R"),
    list(
        list(name = "Seattle"), list(name = "New York"),
        list(name = "Bellevue"), list(name = "Olympia")
    )
)

expect_identical(
    j_query(ndjson_file, "{name: name}", as = "R"),
    list(
        list(name = "Seattle"), list(name = "New York"),
        list(name = "Bellevue"), list(name = "Olympia")
    )
)
expect_identical(
    j_query(ndjson_file, "{name: name}", as = "R", n_records = 2),
    list(
        list(name = "Seattle"), list(name = "New York")
    )
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

expect_identical(
    j_pivot(json, "/locations/0"),
    '{"name":["Seattle"],"state":["WA"]}'
)

expect_identical(
    j_pivot(json_file, "locations[]", as = "R"),
    list(
        name = c("Seattle", "New York", "Bellevue", "Olympia"), 
        state = c("WA", "NY", "WA", "WA")
    )
)

expect_identical(
    j_pivot(ndjson_file, "", as = "R"),
    list(
        name = c("Seattle", "New York", "Bellevue", "Olympia"), 
        state = c("WA", "NY", "WA", "WA")
    )
)

expect_error(j_pivot(json, "locations[0].name"))

## j_pivot ndjson

ndjson_con <- tempfile(fileext = ".ndjson")

json <- '[{"a": 1}, {"a": 2, "b": 3}]' # additional key in second object
ndjson_vector <- c('{"a": 1}', '{"a": 2, "b": 3}')
writeLines(ndjson_vector, ndjson_con)
expected <- '{"a":[1,2],"b":[null,3]}'
expect_identical(j_pivot(json), expected)
expect_identical(j_pivot(ndjson_vector), expected)
expect_identical(j_pivot(ndjson_con), expected)

json <- '[{"a": 2, "b": 3}, {"a": 1}]' # fewer keys in second object
ndjson_vector <- c('{"a": 2, "b": 3}', '{"a": 1}')
writeLines(ndjson_vector, ndjson_con)
expected <- '{"a":[2,1],"b":[3,null]}'
expect_identical(j_pivot(json), expected)
expect_identical(j_pivot(ndjson_vector), expected)
expect_identical(j_pivot(ndjson_con), expected)

json <- '[{"a": 1},{"a": 2},{"a": 3, "b": 4},{"c": 5}]' # complex
ndjson_vector <- c('{"a": 1}', '{"a": 2}', '{"a": 3, "b": 4}', '{"c": 5}')
writeLines(ndjson_vector, ndjson_con)
expected <- '{"a":[1,2,3,null],"b":[null,null,4,null],"c":[null,null,null,5]}'
expect_identical(j_pivot(json), expected)
expect_identical(j_pivot(ndjson_vector), expected)
expect_identical(j_pivot(ndjson_con), expected)

expect_identical(j_data_type(json), "json") # FIXME: can we be smarter
expect_identical(j_data_type(ndjson_vector), "ndjson")
