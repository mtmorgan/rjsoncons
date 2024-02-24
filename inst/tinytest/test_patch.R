data <- system.file(package = "rjsoncons", "extdata", "patch_data.json")
json <- paste0(trimws(readLines(data, warn = FALSE)), collapse = "")

## j_patch_apply()

expect_identical(j_patch_apply(json, '[]'), json)
expect_identical(j_patch_apply(json, '[]', as = "R"), as_r(json))

patch <- '[{"op": "remove", "path": "/biscuits"}]'
expect_identical(j_patch_apply(json, patch), "{}")

json_r = as_r(json)                                  # 'data' is an R object
expect_identical(j_patch_apply(json_r, patch, auto_unbox = TRUE), "{}")

patch_r = as_r(patch)                                # 'patch' is an R object
expect_identical(j_patch_apply(json, patch_r, auto_unbox = TRUE), "{}")
expect_identical(j_patch_apply(json_r, patch_r, auto_unbox = TRUE), "{}")

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
expect_identical(
    j_patch_from(j_patch_apply(json, patch, as = "R"), json, auto_unbox = TRUE),
    '[{"op":"add","path":"/biscuits/1","value":{"name":"Choco Leibniz"}}]'
)
expect_identical(
    j_patch_from(j_patch_apply(json, patch), json_r, auto_unbox = TRUE),
    '[{"op":"add","path":"/biscuits/1","value":{"name":"Choco Leibniz"}}]'
)
