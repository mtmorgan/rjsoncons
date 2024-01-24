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
    chunk_size <- 1024L * 8L

    ex <- cpp_r_json_init(object_names, path, as, data_type, path_type)
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
        n_records <- max(n_records - chunk_size, 0L)
        if (verbose)
            cli::cli_progress_update()
        cpp_function(ex, ndjson, object_names)
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

    if (.is_j_data_type_connection(data_type)) {
        r_function <- ndjson_connection
    } else {
        r_function <- ndjson_character
    }

    r_function(
        cpp_r_json_query,
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

    if (.is_j_data_type_connection(data_type)) {
        r_function <- ndjson_connection
    } else {
        r_function <- ndjson_character
    }

    as0 <- ifelse(identical(as, "string"), "string", "R")
    pivot <- r_function(
        cpp_r_json_pivot,
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
        result <- pivot
    }

    switch(
        as,
        string = result,
        R = result,
        data.frame = as.data.frame(result),
        tibble = tibble::as_tibble(result)
    )
}
