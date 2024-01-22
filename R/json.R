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
    if (identical(data_type, "R"))
        data_type <- "json"

    data_type <- head(data_type, 1L)
    ex <- cpp_r_json_init(object_names, path, as, data_type, path_type)
    cpp_r_json_query(ex, data, object_names)
    cpp_r_json_finish(ex, object_names)[[1]]
}

json_pivot <-
    function(data, path, object_names, as, ..., path_type, data_type)
{
    if (any(c("file", "url") %in% data_type))
        data <- readLines(data, warn = FALSE)
    data <- .as_json_string(data, ..., data_type = data_type[[1]])
    if (identical(data_type, "R"))
        data_type <- "json"

    as0 <- ifelse(identical(as, "string"), as, "R")
    ex <- cpp_r_json_init(object_names, path, as0, data_type, path_type)
    cpp_r_json_pivot(ex, data, object_names)
    result <- cpp_r_json_finish(ex, object_names)[[1]]

    switch(
        as,
        string = ,
        R = result,
        data.frame = as.data.frame(result),
        tibble = tibble::as_tibble(result)
    )
}
