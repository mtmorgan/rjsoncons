expect_identical(jsonpivot("null"), "null")
expect_identical(jsonpivot('[]'), "{}")
expect_identical(jsonpivot('[1]'), "{}") # no object names, so no fields...
expect_identical(jsonpivot('[1, 2]'), "{}")
expect_identical(jsonpivot('[{}]'), "{}")
expect_identical(jsonpivot('[{"a": 1}]'), '{"a":[1]}')
expect_identical(jsonpivot('[{"a": 1, "b": 2}]'), '{"a":[1],"b":[2]}')
expect_identical(
    jsonpivot('[{"a": 1, "b": 2},{"a": 3, "b": 4}]'),
    '{"a":[1,3],"b":[2,4]}'
)
expect_identical(
    jsonpivot('[{"a": 1, "b": 2},{"a": 3, "b": null}]'),
    '{"a":[1,3],"b":[2,null]}'
)

## missing keys -- visit all objects and accumulate names
expect_identical(
    jsonpivot('[{"a": 1, "b": 2}, {"a": 3}]'),
    '{"a":[1,3],"b":[2,null]}'
)
expect_identical(
    jsonpivot('[{"a": 1}, {"b": 2}]'),
    '{"a":[1,null],"b":[null,2]}'
)
expect_identical(
    jsonpivot('[1, {"a": 2}, 3]'),
    '{"a":[null,2,null]}'
)

## object_names
expect_identical(
    jsonpivot('[{"a": 1, "z": 2, "m": 3}]', "asis"),
    '{"a":[1],"z":[2],"m":[3]}'
)
expect_identical(
    jsonpivot('[{"a": 1, "z": 2, "m": 3}]', "sort"),
    '{"a":[1],"m":[3],"z":[2]}'
)

## errors
expect_error(jsonpivot("1"), "'data' must be a JSON object")

## as = "R"
expect_identical(
    jsonpivot('[{"a": 1, "b": 2}, {"a": 3, "b": 4}]', as = "R"),
    list(a = c(1L, 3L), b = c(2L, 4L))
)
expect_identical(
    jsonpivot('[{"a": 1, "b": 2}, {"a": 3}]', as = "R"),
    list(a = c(1L, 3L), b = list(2L, NULL))
)
