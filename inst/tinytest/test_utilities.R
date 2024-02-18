.is_scalar_character <- rjsoncons:::.is_scalar_character

expect_true(.is_scalar_character("a"))
expect_false(.is_scalar_character(character()))
expect_false(.is_scalar_character(c("a", "b")))
expect_false(.is_scalar_character(NA_character_))
expect_false(.is_scalar_character(""))
expect_true(.is_scalar_character("", z.ok = TRUE))

## C++ utilities.h
## 'object_names' should be in c("asis", "sort")
json <- '{"a": 1, "c": 3, "b": 2}'
expect_identical(
    rjsoncons:::cpp_as_r(json, "json", "asis"),
    list(list(a = 1L, c = 3L, b = 2L))
)
expect_error(rjsoncons:::cpp_as_r(json, "json", "foo"), "'foo' unknown")
