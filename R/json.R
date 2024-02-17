json_query <-
    function(data, path, object_names, as, ..., path_type, data_type)
{
    if (.is_j_data_type_connection(data_type))
        data <- readLines(data, warn = FALSE)
    data_type <- head(data_type, 1L)

    data <- .as_json_string(data, ..., data_type = data_type)
    if (identical(data_type, "R"))
        data_type <- "json"

    ex <- cpp_r_json_init(object_names, path, as, data_type, path_type)
    cpp_r_json_query(ex, data, object_names)
    cpp_r_json_finish(ex, object_names)[[1]]
}

json_pivot <-
    function(data, path, object_names, as, ..., path_type, data_type)
{
    if (.is_j_data_type_connection(data_type))
        data <- readLines(data, warn = FALSE)
    data_type <- head(data_type, 1L)

    data <- .as_json_string(data, ..., data_type = data_type)
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
