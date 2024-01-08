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

.as_json_string <-
    function(x, ..., data_type)
{
    switch(
        data_type,
        json = paste(x, collapse = "\n"),
        ndjson = x,
        R = as.character(jsonlite::toJSON(x, ...))
    )
}
