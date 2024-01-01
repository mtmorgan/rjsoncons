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

## j_path_type

expect_identical(j_path_type(""), "JSONpointer")
expect_identical(j_path_type("/locations/0/name"), "JSONpointer")
expect_identical(j_path_type("$.locations[0].name"), "JSONpath")
expect_identical(j_path_type("locations[0].name"), "JMESpath")
expect_identical(j_path_type("@"), "JMESpath")

expect_identical(j_path_type(" $.locations[0].name"), "JSONpath")

expect_error(j_path_type(character()))
expect_error(j_path_type(c("", "")))
expect_error(j_path_type(NA_character_))
