#' @useDynLib rjsoncons, .registration = TRUE
NULL

#' @rdname version
#'
#' @title Version of jsoncons C++ library
#'
#' @description `version()` reports the version of the C++ jsoncons
#'     library in use.
#'
#' @return `version()` returns a character(1) major.minor.patch
#'     version string, possibly with git hash for between-release
#'     version.
#'
#' @examples
#' version()
#'
#' @export
version <- function() {
    paste(cpp_version(), "[+57967655d]")
}
