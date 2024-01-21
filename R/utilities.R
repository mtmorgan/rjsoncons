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
