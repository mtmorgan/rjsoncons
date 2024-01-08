ndjson_query_character <-
    function(data, path, object_names, as, n_records, verbose, path_type)
{
    ndjson <- head(data, n_records)
    result <- cpp_ndjson_query(ndjson, path, object_names, as, path_type)

    if (identical(as, "string")) {
        result <- unlist(result)
    }
    result
}

ndjson_query_connection <-
    function(
        data, path, object_names, as, n_records, verbose,
        path_type, data_type
    )
{
    ## need an open connection for iteration
    if (identical(data_type[[2]], "file")) {
        fl <- gzfile(data, "rb")
        on.exit(close(fl))
    } else { # url
        fl <- gzcon(url(data, "rb"))
        on.exit(close(fl))
    }
    chunk_size <- 1024L * 8L

    result <- list()
    i <- lines <- 0L
    if (verbose)
        cli::cli_progress_message("{lines} ndjson records processed")
    repeat {
        chunk_size <- min(chunk_size, n_records)
        ndjson <- readLines(fl, chunk_size)
        if (!length(ndjson))
            break
        i <- i + 1L
        lines <- lines + length(ndjson)
        if (verbose)
            cli::cli_progress_update()
        n_records <- max(n_records - chunk_size, 0L)
        result[[i]] <-
            cpp_ndjson_query(ndjson, path, object_names, as, path_type)
    }
    if (verbose)
        cli::cli_progress_done()

    unlist(result, recursive = identical(as, "string"))
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

    if (any(c("file", "url") %in% data_type)) {
        ndjson_query_connection(
            data, path, object_names, as, n_records, verbose,
            path_type, data_type
        )
    } else {
        ndjson_query_character(
            data, path, object_names, as, n_records, verbose, path_type
        )
    }
}

ndjson_pivot <-
    function(
        data, path, object_names, as, n_records = Inf,
        path_type, data_type
    )
{
    stop("'j_pivot()' not yet implemented for 'NDJSON' files")
}
