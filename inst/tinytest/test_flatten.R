##
## JSON
##

json_file <- system.file(package = "rjsoncons", "extdata", "flatten_data.json")
json <- paste0(trimws(readLines(json_file, warn = FALSE)), collapse = "")
ojson <- paste0(
'{',
    '"warnings":{',
        '"0":"Phone number missing country code",',
        '"1":"State code missing",',
        '"2":"Zip code missing"',
    '},',
    '"discards":{',
        '"1000":"Record does not exist",',
        '"1004":"Queue limit exceeded",',
        '"1010":"Discarding timed-out partial msg"',
    '}',
'}')
flat <- paste0(
    '{',
    '"/discards/1000":"Record does not exist",',
    '"/discards/1004":"Queue limit exceeded",',
    '"/discards/1010":"Discarding timed-out partial msg",',
    '"/warnings/0":"Phone number missing country code",',
    '"/warnings/1":"State code missing",',
    '"/warnings/2":"Zip code missing"',
    '}'
)
oflat <- paste0(
    '{',
    '"/warnings/0":"Phone number missing country code",',
    '"/warnings/1":"State code missing",',
    '"/warnings/2":"Zip code missing",',
    '"/discards/1000":"Record does not exist",',
    '"/discards/1004":"Queue limit exceeded",',
    '"/discards/1010":"Discarding timed-out partial msg"',
    '}'
)
flat_r <- list(
    `/discards/1000` = "Record does not exist",
    `/discards/1004` = "Queue limit exceeded",
    `/discards/1010` = "Discarding timed-out partial msg",
    `/warnings/0` = "Phone number missing country code",
    `/warnings/1` = "State code missing",
    `/warnings/2` = "Zip code missing"
)
named_list <- structure(list(), names = character(0))

## .j_find_keys_from_path

.j_find_keys_from_path <- rjsoncons:::.j_find_keys_from_path

expect_identical(.j_find_keys_from_path("/", "JSONpointer"), list(character()))
expect_identical(.j_find_keys_from_path("/a", "JSONpointer"), list("a"))
expect_identical(
    .j_find_keys_from_path("/a/b", "JSONpointer"),
    list(c("a", "b"))
)
expect_identical(
    .j_find_keys_from_path("/a/1", "JSONpointer"),
    list(c("a", "1"))
)

expect_identical(.j_find_keys_from_path("$", "JSONpath"), list(character()))
expect_identical(.j_find_keys_from_path("$['a']", "JSONpath"), list("a"))
expect_identical(
    .j_find_keys_from_path("$['a']['b']", "JSONpath"),
    list(c("a", "b"))
)
expect_identical(
    .j_find_keys_from_path("$['a'][1]", "JSONpath"),
    list(c("a", "1"))
)

expect_error(.j_find_keys_from_path("@", "JMESpath"))

## j_flatten

expect_identical(j_flatten(json), flat)
expect_identical(j_flatten(json, as = "R"), flat_r)

expect_identical(j_flatten(json_file, "asis"), flat)
expect_identical(j_flatten(json_file, "asis", as = "R"), flat_r)

expect_identical(j_flatten(ojson), oflat)
expect_identical(j_flatten(ojson, "sort"), flat)

## j_find_values

expect_identical(j_find_values(json, "State code missing"), flat_r[5])
expect_identical(
    j_find_values(json, c("State code missing", "Queue limit exceeded")),
    flat_r[c(2, 5)]
)

expect_identical(
    j_find_values(
        json, c("State code missing", "Queue limit exceeded"),
        as = "data.frame"
    ),
    data.frame(
        path = names(flat_r[c(2, 5)]),
        value = unlist(flat_r[c(2, 5)], use.names = FALSE)
    ),
    info = "as = 'data.frame'"
)
expect_identical( # as = "tibble"
    j_find_values(
        json, c("State code missing", "Queue limit exceeded"),
        as = "tibble"
    ),
    tibble::tibble(
        path = names(flat_r[c(2, 5)]),
        value = unlist(flat_r[c(2, 5)], use.names = FALSE)
    ),
    info = "as = 'tibble'"
)

expect_identical(j_find_values(json, "foo"), named_list)

## j_find_values_grep

expect_identical(j_find_values_grep(json, "missing"), flat_r[4:6])

## j_find_keys

expect_identical(j_find_keys(json, "warnings"), flat_r[4:6])
expect_identical(j_find_keys(json, c("1000", "1")), flat_r[c(1, 5)])

## j_find_keys_grep

expect_identical(j_find_keys_grep(json, "warn"), flat_r[4:6])
expect_identical(j_find_keys_grep(json, "ard.*10$"), flat_r[3])

##
## NDJSON
##

ndjson_file <- system.file(package = "rjsoncons", "extdata", "example.ndjson")
flat_ndjson <- c(
    '{"/name":"Seattle","/state":"WA"}', '{"/name":"New York","/state":"NY"}',
    '{"/name":"Bellevue","/state":"WA"}', '{"/name":"Olympia","/state":"WA"}'
)

## j_flatten

expect_identical(j_flatten(ndjson_file), flat_ndjson)
expect_identical(j_flatten(ndjson_file, n_records = 2), flat_ndjson[1:2])

## j_find_values*()

expect_identical(
    j_find_values(ndjson_file, "WA"),
    list(
        list(`/state` = "WA"), named_list,
        list(`/state` = "WA"), list(`/state` = "WA")
    )
)
expect_identical(
    j_find_values(ndjson_file, "WA", n_records = 2),
    list(list(`/state` = "WA"), named_list)
)
expect_identical(
    j_find_values_grep(ndjson_file, "e"),
    list(
        list(`/name` = "Seattle"), list(`/name` = "New York"),
        list(`/name` = "Bellevue"), named_list
    )
)

expect_identical(
    j_find_values(ndjson_file, "WA"),
    list(
        list(`/state` = "WA"), named_list,
        list(`/state` = "WA"), list(`/state` = "WA")
    )
)
expect_identical(
    j_find_values(ndjson_file, "WA", n_records = 2),
    list(
        list(`/state` = "WA"), named_list
    )
)

expect_identical(
    j_find_values_grep(ndjson_file, "e", n_records = 2),
    list(
        list(`/name` = "Seattle"), list(`/name` = "New York")
    )
)

## j_find_keys*()

expect_identical(
    j_find_keys(ndjson_file, "name"),
    list(
        list(`/name` = "Seattle"), list(`/name` = "New York"),
        list(`/name` = "Bellevue"), list(`/name` = "Olympia")
    )
)
expect_identical(
    j_find_keys(ndjson_file, "name", n_records = 2),
    list(
        list(`/name` = "Seattle"), list(`/name` = "New York")
    )
)

expect_identical(
    j_find_keys_grep(ndjson_file, "ame", n_records = 2),
    list(
        list(`/name` = "Seattle"), list(`/name` = "New York")
    )
)
