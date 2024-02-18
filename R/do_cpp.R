do_cpp <-
    function(fun, con_fun, data, data_type, ..., n_records, verbose)
{
    if (.is_j_data_type_connection(data_type)) {
        con <- .as_unopened_connection(data, data_type)
        open(con, "rb")
        on.exit(close(con))
        result <- con_fun(con, data_type[[1]], ..., n_records, verbose)
    } else {
        if (identical(data_type, "R"))
            data_type <- "json"
        result <- fun(data, data_type, ...)
    }

    result
}
