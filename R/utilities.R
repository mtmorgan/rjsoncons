.is_scalar <-
    function(x)
{
    identical(length(x), 1L) && !is.na(x)
}

.is_scalar_character <-
    function(x, z.ok = FALSE)
{
    .is_scalar(x) && is.character(x) && (z.ok || nzchar(x))
}

.is_scalar_numeric <-
    function(x)
{
    .is_scalar(x) && is.numeric(x)
}

.is_scalar_logical <-
    function(x)
{
    .is_scalar(x) && is.logical(x)
}

.as_json_string <-
    function(data, data_type, ...)
{
    if (.is_j_data_type_connection(data_type)) {
        data
    } else if (identical(data_type, "R")) {
        as.character(jsonlite::toJSON(data, ...))
    } else if (identical(data_type, "json")) {
        paste(data, collapse = "\n")
    } else { # ndjson
        data
    }
}

.as_unopened_connection <-
    function(data, data_type)
{
    if (.is_j_data_type_file(data_type)) {
        gzfile(data)
    } else { # url
        gzcon(url(data))
    }
}
