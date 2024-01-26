#' @importFrom utils head
ndjson_character <-
    function(
        cpp_function, data, path, object_names, as, n_records, verbose,
        path_type, data_type
    )
{
    ndjson <- head(data, n_records)
    data_type <- head(data_type, 1L)
    ex <- cpp_r_json_init(object_names, path, as, data_type, path_type)
    cpp_function(ex, data, object_names)
    cpp_r_json_finish(ex, object_names)
}

ndjson_connection <-
    function(
        cpp_function, data, path, object_names, as, n_records, verbose,
        path_type, data_type
    )
{
    ## need an open connection for iteration
    if (.is_j_data_type_file(data_type)) {
        fl <- gzfile(data, "rb")
        on.exit(close(fl))
    } else { # url
        fl <- gzcon(url(data, "rb"))
        on.exit(close(fl))
    }
    data_type <- head(data_type, 1L)
    chunk_size <- as.integer(2^20) # 1 Mb chunks
    ex <- cpp_r_json_init(object_names, path, as, data_type, path_type)
    n_lines <- 0L
    prefix <- raw()
    if (verbose)
        cli::cli_progress_message("{n_lines} records processed")
    repeat {
        if (n_records <= 0L)
            break
        if (verbose)
            cli::cli_progress_update()

        bin <- readBin(fl, raw(), chunk_size)
        if (!length(bin))
            break
        result <- cpp_function(ex, prefix, bin, n_records, object_names)
        prefix <- result$prefix
        n_lines <- n_lines + result$n_lines
        n_records <- n_records - result$n_lines
    }
    if (verbose)
        cli::cli_progress_done()

    cpp_r_json_finish(ex, object_names)
}

## j_query("data/gharchive_gz/2023-02-08-0.json.gz", "{id: id, type: type}", n_records = 5)
ndjson_query <-
    function(
        data, path, object_names, as, n_records = Inf, verbose = FALSE,
        path_type, data_type
    )
{
    ## validation
    stopifnot(
        .is_scalar_numeric(n_records), n_records >= 0,
        .is_scalar_logical(verbose)
    )

    n_records <- as.integer(min(n_records, .Machine$integer.max))
    if (.is_j_data_type_connection(data_type)) {
        r_function <- ndjson_connection
        cpp_function <- cpp_r_json_query_raw
    } else {
        r_function <- ndjson_character
        cpp_function <- cpp_r_json_query
    }

    r_function(
        cpp_function,
        data, path, object_names, as, n_records, verbose,
        path_type, data_type
    )
}

## j_pivot("data/gharchive_gz/2023-02-08-0.json.gz", "{id: id, type: type}", n_records = 5)
ndjson_pivot <-
    function(
        data, path, object_names, as, n_records = Inf, verbose = FALSE,
        path_type, data_type
    )
{
    ## validation
    stopifnot(
        .is_scalar_numeric(n_records), n_records >= 0,
        .is_scalar_logical(verbose)
    )

    n_records <- as.integer(min(n_records, .Machine$integer.max))
    if (.is_j_data_type_connection(data_type)) {
        r_function <- ndjson_connection
        cpp_function <- cpp_r_json_pivot_raw
    } else {
        r_function <- ndjson_character
        cpp_function <- cpp_r_json_pivot
    }

    as0 <- ifelse(identical(as, "string"), "string", "R")
    pivot <- r_function(
        cpp_function,
        data, path, object_names, as0, n_records, verbose,
        path_type, data_type
    )

    ## process pivot return types to output form
    if (identical(as, "string")) {
        result <- unlist(pivot, recursive = TRUE)
    } else if (.is_j_data_type_connection(data_type)) {
        ## unnest list-of-named chunks
        keys <- names(pivot[[1]])
        names(keys) <- keys
        result <- lapply(keys, \(key, pivot) {
            do.call("c", lapply(pivot, `[[`, key))
        }, pivot)
    } else {
        result <- pivot[[1]]
    }

    switch(
        as,
        string = result,
        R = result,
        data.frame = as.data.frame(result),
        tibble = tibble::as_tibble(result)
    )
}
