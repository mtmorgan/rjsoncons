json <- '{
  "locations": [
    {"name": "Seattle", "state": "WA"},
    {"name": "New York", "state": "NY"},
    {"name": "Bellevue", "state": "WA"},
    {"name": "Olympia", "state": "WA"}
  ]
 }'

datalist <- jsonlite::fromJSON(json, simplifyVector = FALSE)

## version

expect_true(
    is.character(version())
)

## jsonpath

expect_identical(
    jsonpath(json, "$..name"),
    '["Seattle","New York","Bellevue","Olympia"]'
)

expect_identical(
    ## auto_unbox = FALSE
    jsonpath(datalist, "$..name"),
    '[["Seattle"],["New York"],["Bellevue"],["Olympia"]]'
)

expect_identical(
    jsonpath(datalist, "$..name", auto_unbox = TRUE),
    '["Seattle","New York","Bellevue","Olympia"]'
)

expect_error(
    jsonpath("Seattle", "$[0]")
)

expect_identical(
    jsonpath(I("Seattle"), "$[0]"),
    '["Seattle"]'
)

## jmespath

expect_identical(
    jmespath(json, "locations[?state == 'WA'].name | sort(@)"),
    '["Bellevue","Olympia","Seattle"]'
)

expect_identical(
    ## auto_unbox = FALSE, boxed 'state' (e.g., ['WA']) does not match
    ## original filter
    jmespath(datalist, "locations[?state == 'WA'].name | sort(@)"),
    '[]'
)

expect_identical(
    ## auto_unbox = FALSE, query unboxed (`?state[0] == 'WA'`) state
    jmespath(datalist, "locations[?state[0] == 'WA'].name") ,
    '[["Seattle"],["Bellevue"],["Olympia"]]'
)

expect_identical(
    ## auto_unbox = FALSE, sort unboxed (`@[]`) result values
    jmespath(datalist, "locations[?state[0] == 'WA'].name | sort(@[])") ,
    '["Bellevue","Olympia","Seattle"]'
)

expect_identical(
    ## auto_unbox = FALSE, unbox name
    jmespath(datalist, "locations[?state[0] == 'WA'].name[] | sort(@)") ,
    '["Bellevue","Olympia","Seattle"]'
)

expect_identical(
    jmespath(
        datalist, "locations[?state == 'WA'].name | sort(@)", auto_unbox = TRUE
    ),
    '["Bellevue","Olympia","Seattle"]'
)
