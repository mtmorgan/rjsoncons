named_list = structure(list(), names = character())

## scalar

expect_true(is.null(as_r('null')))

expect_true(as_r('true'))

expect_identical(as_r('-1'), -1L)

expect_identical(as_r('1'), 1L)

expect_identical(
    ## .Machine$integer.max is uint64 in JSON, integer in R
    as_r(as.character(.Machine$integer.max)),
    .Machine$integer.max
)

expect_identical(
    ## .Machine$integer.max + 1 is uint64 in JSON, numeric in R
    as_r(as.character(.Machine$integer.max + 1)),
    .Machine$integer.max + 1
)

expect_identical(
    as_r(as.character(-.Machine$integer.max)),
    -.Machine$integer.max
)

expect_identical(
    ## INT_MIN is 'NA'
    as_r(as.character(-.Machine$integer.max - 1)),
    -.Machine$integer.max - 1
)

expect_identical(as_r('-1.0'), -1)

expect_identical(as_r('1.0'), 1)

expect_identical(as_r('"a"'), "a")

## object

expect_identical(as_r('{}'), named_list)

expect_identical(as_r('{"a": 1}'), list(a = 1L))

expect_identical(as_r('{"a": 1.0}'), list(a = 1))

expect_identical(as_r('{"b": 2, "a": 1.0}'), list(b = 2L, a = 1))

expect_identical(as_r('{"b": 2, "a": 1.0}', "sort"), list(a = 1, b = 2L))

expect_identical( # nested
    as_r('{"a": 1, "b": { "c": 2, "d": [3, 4, 5] }, "e": {}}'),
    list(a = 1L, b = list(c = 2L, d = 3:5), e = named_list)
)

## array -- homogenous

expect_identical(as_r('[]'), list())

expect_identical(as_r('[null]'), list(NULL))

expect_identical(as_r('[null, null]'), list(NULL, NULL))

expect_identical(as_r('[true, false]'), c(TRUE, FALSE))

expect_identical(as_r('[2, 1]'), 2:1)

expect_identical(as_r('[2.0, 1.0]'), c(2, 1))

expect_identical(as_r('["b", "a"]'), c("b", "a"))

## array of arrays

expect_identical(as_r('[[]]'), list(list()))

expect_identical(as_r('[[],[]]'), list(list(), list()))

expect_identical(as_r('[[1, 2]]'), list(1:2))

expect_identical(as_r('[[1, 2],[3]]'), list(1:2, 3L))

expect_identical(as_r('[[1, 2],[3], [null]]'), list(1:2, 3L, list(NULL)))

expect_identical(as_r('[[1, 2],[3], null]'), list(1:2, 3L, NULL))

## array of objects

expect_identical(as_r('[{}]'), list(named_list))

expect_identical(as_r('[{}, {}]'), list(named_list, named_list))

expect_identical(
    as_r('[{"a": 1}, {"b": 2.0, "c": [3, 4]}]'),
    list(list(a = 1L), list(b = 2, c = 3:4))
)

## array -- heterogenous; integer / double -> numeric

expect_identical(as_r('[2, 1.0]'), c(2, 1))

expect_identical(as_r('[2.0, 1]'), c(2, 1))

## array -- heterogenous -> object

expect_identical(as_r('[true, 1]'), list(TRUE, 1L))

expect_identical(as_r('[1, true]'), list(1L, TRUE))

expect_identical(as_r('[true, 1.0]'), list(TRUE, 1))

expect_identical(as_r('[true, "a"]'), list(TRUE, "a"))

expect_identical(as_r('[true, {"a": 2}]'), list(TRUE, list(a = 2L)))

expect_identical(as_r('[{"a": 2}, true]'), list(list(a = 2L), TRUE))

expect_identical(as_r('[1, "a"]'), list(1L, "a"))

expect_identical(as_r('[1, {"a": 2}]'), list(1L, list(a = 2L)))

## asis / sort

expect_identical(as_r('{"b": 2, "a": 1}', "sort"), list(a = 1L, b = 2L))

expect_identical(as_r('[{"b": 2, "a": 1}]', "sort"), list(list(a = 1L, b = 2L)))

## R, json, ndjson, connections

json <- list(
    locations = list(
        list(name = "Seattle", state = "WA"),
        list(name = "New York", state = "NY"),
        list(name = "Bellevue", state = "WA"),
        list(name = "Olympia", state = "WA")
    ))

json_file <- system.file(package = "rjsoncons", "extdata", "example.json")

ndjson_file <- system.file(package = "rjsoncons", "extdata", "example.ndjson")

expect_identical(as_r(json_file), json)

expect_identical(as_r(readLines(json_file)), json)

expect_identical(as_r(paste(readLines(json_file), collapse = "\n")), json)

expect_identical(as_r(ndjson_file), json$locations)

expect_identical(as_r(readLines(ndjson_file)), json$locations)

if (has_jsonlite)
    expect_identical(as_r(json), json) # R -> R
