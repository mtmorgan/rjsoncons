.as_json_string <-
    function(x, ..., data_type)
{
    if (identical(data_type, "R")) {
        as.character(jsonlite::toJSON(x, ...))
    } else {
        paste(x, collapse = "\n")
    }
}

json_query <-
    function(data, path, object_names, as, ..., path_type, data_type)
{
    if (any(c("file", "url") %in% data_type))
        data <- readLines(data, warn = FALSE)
    data <- .as_json_string(data, ..., data_type = data_type[[1]])

    cpp_j_query(data, path, object_names, as, path_type)
}

json_pivot <-
    function(data, path, object_names, as, ..., path_type, data_type)
{
    if (any(c("file", "url") %in% data_type))
        data <- readLines(data, warn = FALSE)
    data <- .as_json_string(data, ..., data_type = data_type[[1]])

    switch(
        as,
        string = cpp_j_pivot(data, path, object_names, as, path_type),
        R = cpp_j_pivot(data, path, object_names, as = "R", path_type),
        data.frame =
            cpp_j_pivot(data, path, object_names, as = "R", path_type) |>
            as.data.frame(),
        tibble =
            cpp_j_pivot(data, path, object_names, as = "R", path_type) |>
            tibble::as_tibble()
    )
}
