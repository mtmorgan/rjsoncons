json <- '{
  "locations": [
    {"name": "Seattle", "state": "WA"},
    {"name": "New York", "state": "NY"},
    {"name": "Bellevue", "state": "WA"},
    {"name": "Olympia", "state": "WA"}
  ]
 }'

if (has_jsonlite)
    datalist <- jsonlite::fromJSON(json, simplifyVector = FALSE)

## version

expect_identical(version(), "0.173.4 [+57967655d]")

## jsonpath

expect_identical(
    jsonpath(json, "$..name"),
    '["Seattle","New York","Bellevue","Olympia"]'
)

if (has_jsonlite) {
    expect_identical(
        ## auto_unbox = FALSE
        jsonpath(datalist, "$..name"),
        '[["Seattle"],["New York"],["Bellevue"],["Olympia"]]'
    )

    expect_identical(
        jsonpath(datalist, "$..name", auto_unbox = TRUE),
        '["Seattle","New York","Bellevue","Olympia"]'
    )

    expect_identical(
        jsonpath(I("Seattle"), "$[0]"),
        '["Seattle"]'
    )
}

expect_error(
    jsonpath("Seattle", "$[0]")
)

expect_identical(
    jsonpath('{"b":"1","a":"2"}', "$", "asis"),
    '[{"b":"1","a":"2"}]'
)

expect_identical(
    jsonpath('{"b":"1","a":"2"}', "$"),
    jsonpath('{"b":"1","a":"2"}', "$", "asis"),
)

expect_identical(
    jsonpath('{"b":"1","a":"2"}', "$", "sort"),
    '[{"a":"2","b":"1"}]'
)

expect_error(jsonpath('{"b":"1","a":"2"}', "$", "ASIS"))

## jmespath

expect_identical(
    jmespath(json, "locations[?state == 'WA'].name | sort(@)"),
    '["Bellevue","Olympia","Seattle"]'
)

if (has_jsonlite) {
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
            datalist, "locations[?state == 'WA'].name | sort(@)",
            auto_unbox = TRUE
        ),
        '["Bellevue","Olympia","Seattle"]'
    )
}

expect_identical(
    jmespath('{"b":"1","a":"2"}', "@", "asis"),
    '{"b":"1","a":"2"}'
)

expect_identical(
    jmespath('{"b":"1","a":"2"}', "@"),
    jmespath('{"b":"1","a":"2"}', "@", "asis"),
)

expect_identical(
    jmespath('{"b":"1","a":"2"}', "@", "sort"),
    '{"a":"2","b":"1"}'
)

expect_error(jmespath('{"b":"1","a":"2"}', "@", "ASIS"))

## segfault on fedora builder, rjsoncons/1.0.1; see
## https://github.com/danielaparker/jsoncons/issues/471

expect_identical(
    jmespath(json, "{ name: locations[].name }"),
    '{"name":["Seattle","New York","Bellevue","Olympia"]}'
)

## jsonpointer

expect_identical(jsonpointer(json, "/locations/1/name"), "New York")

expect_identical(
    ## pointer '""' is root document
    jsonpointer('{"a": 1, "": 2}', ""),
    '{"a":1,"":2}'
)

expect_identical(jsonpointer('{"a": 1, "": 2}', ""), '{"a":1,"":2}')

expect_identical(
    ## '/' alone is unnamed element
    jsonpointer('{"a": 1, "": 2}', "/"),
    '2'
)

expect_error(jsonpointer('{}', "/"), 'Key not found')

expect_error(jsonpointer('{"a": 1}', "/"), 'Key not found')

expect_identical(
    ## object_names in response
    jsonpointer('{"b": 1, "a": 2}', "", "asis"),
    "{\"b\":1,\"a\":2}"
)

expect_identical(
    ## as = "R"
    jsonpointer(json, "/locations/0", as = "R"),
    list(name = "Seattle", state = "WA")
)
