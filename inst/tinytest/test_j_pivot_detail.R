expect_identical(j_pivot("null"), "{}")
expect_identical(j_pivot('[]'), "{}")
expect_identical(j_pivot('[1]'), "{}") # no object names, so no fields...
expect_identical(j_pivot('[1, 2]'), "{}")
expect_identical(j_pivot('[{}]'), "{}")
expect_identical(j_pivot('[{"a": 1}]'), '{"a":[1]}')
expect_identical(j_pivot('[{"a": 1, "b": 2}]'), '{"a":[1],"b":[2]}')
expect_identical(
    j_pivot('[{"a": 1, "b": 2},{"a": 3, "b": 4}]'),
    '{"a":[1,3],"b":[2,4]}'
)
expect_identical(
    j_pivot('[{"a": 1, "b": 2},{"a": 3, "b": null}]'),
    '{"a":[1,3],"b":[2,null]}'
)

## missing keys -- visit all objects and accumulate names
expect_identical(
    j_pivot('[{"a": 1, "b": 2}, {"a": 3}]'),
    '{"a":[1,3],"b":[2,null]}'
)
expect_identical(
    j_pivot('[{"a": 1}, {"b": 2}]'),
    '{"a":[1,null],"b":[null,2]}'
)
expect_identical(
    j_pivot('[1, {"a": 2}, 3]'),
    '{"a":[null,2,null]}'
)

## object_names
expect_identical(
    j_pivot('[{"a": 1, "z": 2, "m": 3}]', object_names = "asis"),
    '{"a":[1],"z":[2],"m":[3]}'
)
expect_identical(
    j_pivot('[{"a": 1, "z": 2, "m": 3}]', object_names = "sort"),
    '{"a":[1],"m":[3],"z":[2]}'
)

## errors
expect_error(j_pivot("1"), "`j_pivot\\(\\)` 'path' must yield an object or array")

## as = "R"
expect_identical(
    j_pivot('[{"a": 1, "b": 2}, {"a": 3, "b": 4}]', as = "R"),
    list(a = c(1L, 3L), b = c(2L, 4L))
)
expect_identical(
    j_pivot('[{"a": 1, "b": 2}, {"a": 3}]', as = "R"),
    list(a = c(1L, 3L), b = list(2L, NULL))
)
