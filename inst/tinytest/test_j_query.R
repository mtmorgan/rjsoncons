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

expect_error(j_pivot(json, "locations[0].name"))
