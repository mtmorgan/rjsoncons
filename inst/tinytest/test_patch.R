data <- system.file(package = "rjsoncons", "extdata", "patch_data.json")
json <- paste0(trimws(readLines(data, warn = FALSE)), collapse = "")

## j_patch_apply()

expect_identical(j_patch_apply(json, '[]'), json)
expect_identical(j_patch_apply(json, '[]', as = "R"), as_r(json))

patch <- '[{"op": "remove", "path": "/biscuits"}]'
expect_identical(j_patch_apply(json, patch), "{}")

if (has_jsonlite) {
    json_r = as_r(json) # 'data' is an R object
    expect_identical(j_patch_apply(json_r, patch, auto_unbox = TRUE), "{}")

    patch_r = as_r(patch) # 'patch' is an R object
    expect_identical(j_patch_apply(json, patch_r, auto_unbox = TRUE), "{}")
    expect_identical(j_patch_apply(json_r, patch_r, auto_unbox = TRUE), "{}")
}

patch <- '{"op": "remove", "path": "/biscuits"}'     # not an array
expect_error(j_patch_apply(json, patch))

patch <- '[{"op": "remover", "path": "/biscuits"}]'  # unknown op
expect_error(j_patch_apply(json, patch))

patch <- '[{"op": "remove", "path": "/biscuits10"}]' # unknown path
expect_error(j_patch_apply(json, patch))

## j_patch_from

expect_identical(j_patch_from(j_patch_apply(json, '[]'), json), '[]')
expect_identical(
    j_patch_from(j_patch_apply(json, '[]'), json, as = "R"),
    list()
)

patch <- '[{"op": "remove", "path": "/biscuits/1"}]'
expect_identical(
    j_patch_from(j_patch_apply(json, patch), json),
    '[{"op":"add","path":"/biscuits/1","value":{"name":"Choco Leibniz"}}]'
)
expect_identical(
    j_patch_from(j_patch_apply(json, patch), json, as = "R"),
    list(list(
        op = "add", path = "/biscuits/1",
        value = list(name = "Choco Leibniz")
    ))
)

if (has_jsonlite) {
    expect_identical(
        j_patch_from(j_patch_apply(json, patch, as = "R"), json, auto_unbox = TRUE),
        '[{"op":"add","path":"/biscuits/1","value":{"name":"Choco Leibniz"}}]'
    )
    expect_identical(
        j_patch_from(j_patch_apply(json, patch), json_r, auto_unbox = TRUE),
        '[{"op":"add","path":"/biscuits/1","value":{"name":"Choco Leibniz"}}]'
    )
}

## j_patch_op

if (has_jsonlite) {
    value0 <- list(name = "Ginger Nut")
    value1 <- list(name = jsonlite::unbox("Ginger Nut"))
    path <- "/biscuits/1"

    expect_identical(
        unclass(j_patch_op("add", path, value = value0)),
        c('[',
          '{"op":"add","path":"/biscuits/1","value":{"name":["Ginger Nut"]}}',
          ']')
    )
    expect_identical(
        unclass(j_patch_op("add", path, value = value1)),
        c('[',
          '{"op":"add","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
          ']')
    )
    expect_identical(
        unclass(j_patch_op("add", path, value = value0, auto_unbox = TRUE)),
        c('[',
          '{"op":"add","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
          ']')
    )
    expect_identical(
        unclass(j_patch_op("remove", path)),
        c('[', '{"op":"remove","path":"/biscuits/1"}', ']')
    )
    expect_identical(
        unclass(j_patch_op("replace", path, value = value1)),
        c('[',
          '{"op":"replace","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
          ']')
    )
    expect_identical(
        unclass(j_patch_op("copy", path, from = path)),
        c('[', '{"op":"copy","path":"/biscuits/1","from":"/biscuits/1"}', ']')
    )
    expect_identical(
        unclass(j_patch_op("move", path, from = path)),
        c('[', '{"op":"move","path":"/biscuits/1","from":"/biscuits/1"}', ']')
    )
    expect_identical(
        unclass(j_patch_op("test", path, value = value1)),
        c('[',
          '{"op":"test","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
          ']')
    )

    ## concatenation and piping
    patch <- j_patch_op("add", path, value = value1)
    expected <- c(
        '[',
        '{"op":"add","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
        ',',
        '{"op":"add","path":"/biscuits/1","value":{"name":"Ginger Nut"}}',
        ']'
    )
    expect_identical(unclass(c(patch, patch)), expected)

    patch1 <- patch |> j_patch_op("add", path, value = value1)
    expect_identical(unclass(patch1), expected)
}
expect_error(j_patch_op())
expect_error(j_patch_op("add"))           # no 'path'
expect_error(j_patch_op("add", path))     # no 'value'
expect_error(j_patch_op("remove"))        # no 'path'
expect_error(j_patch_op("replace", path)) # no 'value'
expect_error(j_patch_op("copy", path))    # no 'from'
expect_error(j_patch_op("move", path))    # no 'from'
expect_error(j_patch_op("test", path))    # no 'value'

if (has_jsonlite) {
    patch <- j_patch_op("remove", "/biscuits")
    expect_identical(j_patch_apply(json, patch), "{}")
}
