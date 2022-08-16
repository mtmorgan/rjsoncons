library(jsonlite)

expect_true(
    is.character(version())
)

json <- '{
  "locations": [
    {"name": "Seattle", "state": "WA"},
    {"name": "New York", "state": "NY"},
    {"name": "Bellevue", "state": "WA"},
    {"name": "Olympia", "state": "WA"}
  ]
 }'

expect_identical(
    jsonpath(json, "$..name") |> fromJSON(),
    c("Seattle", "New York", "Bellevue", "Olympia")
)

expect_identical(
    jsonpath(json, "$..name", auto_unbox = TRUE) |> fromJSON(),
    c("Seattle", "New York", "Bellevue", "Olympia")
)

expect_identical(
    jmespath(json, "locations[?state == 'WA'].name | sort(@)") |>
        fromJSON(),
    c("Bellevue", "Olympia", "Seattle")
)

expect_identical(
    jmespath(
        json, "locations[?state == 'WA'].name | sort(@)", auto_unbox = TRUE
    ) |> fromJSON(),
    c("Bellevue", "Olympia", "Seattle")
)


datalist <- fromJSON(json)
expect_identical(
    jmespath(datalist, "locations[?state == 'WA'].name | sort(@)") |>
        fromJSON(),
    c("Bellevue", "Olympia", "Seattle")
)

expect_identical(
    jmespath(
      datalist, "locations[?state == 'WA'].name | sort(@)", auto_unbox = TRUE
    ) |> fromJSON(),
    c("Bellevue", "Olympia", "Seattle")
)

expect_identical(
    jsonpath(datalist, "$..name") |> fromJSON(),
    c("Seattle", "New York", "Bellevue", "Olympia")
)

expect_identical(
    jsonpath(datalist, "$..name", auto_unbox = TRUE) |> fromJSON(),
    c("Seattle", "New York", "Bellevue", "Olympia")
)
