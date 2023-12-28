.is_scalar <-
    function(x)
{
    identical(length(x), 1L) && !is.na(x)
}

.is_scalar_character <-
    function(x)
{
    .is_scalar(x) && is.character(x) && nzchar(x)
}

.is_scalar_nchar_0 <-
    function(x)
{
    .is_scalar(x) && is.character(x) && identical(nchar(x), 0L)
}
.as_json_string <-
    function(x, ...)
{
    if (.is_scalar_character(x) && !inherits(x, "AsIs")) {
        x
    } else {
        as.character(jsonlite::toJSON(x, ...))
    }
}
