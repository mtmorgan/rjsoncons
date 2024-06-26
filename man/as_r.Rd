% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_r.R
\name{as_r}
\alias{as_r}
\title{Parse JSON or NDJSON to R}
\usage{
as_r(
  data,
  object_names = "asis",
  ...,
  n_records = Inf,
  verbose = FALSE,
  data_type = j_data_type(data)
)
}
\arguments{
\item{data}{a character() JSON string or NDJSON records, or the
name of a file or URL containing JSON or NDJSON, or an \emph{R}
object parsed to a JSON string using \code{jsonlite::toJSON()}.}

\item{object_names}{character(1) order \code{data} object elements
\code{"asis"} (default) or \code{"sort"} before filtering on \code{path}.}

\item{...}{passed to \code{jsonlite::toJSON} when \code{data} is an \emph{R} object.}

\item{n_records}{numeric(1) maximum number of NDJSON records parsed.}

\item{verbose}{logical(1) report progress when parsing large NDJSON
files.}

\item{data_type}{character(1) type of \code{data}; one of \code{"json"},
\code{"ndjson"}, or a value returned by \code{j_data_type()}.}
}
\value{
\code{as_r()} returns an \emph{R} object.
}
\description{
\code{as_r()} transforms JSON or NDJSON to an \emph{R} object.
}
\details{
The \code{as = "R"} argument to \code{j_query()}, \code{j_pivot()}, and the
\code{as_r()} function transform JSON or NDJSON to an \emph{R} object. JSON
and NDJSON can be a character vector, file, or url, or an \emph{R}
object (which is first translated to a JSON string). Main rules are:
\itemize{
\item JSON arrays of a single type (boolean, integer, double, string)
are transformed to \emph{R} vectors of the same length and
corresponding type. A JSON scalar and a JSON vector of length 1
are represented in the same way in \emph{R}.
\item If a JSON 64-bit integer array contains a value larger than \emph{R}'s
32-bit integer representation, the array is transformed to an \emph{R}
numeric vector. NOTE that this results in loss of precision for
64-bit integer values greater than \code{2^53}.
\item JSON arrays mixing integer and double values are transformed to
\emph{R} numeric vectors.
\item JSON objects are transformed to \emph{R} named lists.
}

The vignette reiterates this information and provides additional
details.
}
\examples{
## as_r()
as_r('[1, 2, 3]')       # JSON integer array -> R integer vector
as_r('[1, 2.0, 3]')     # JSON intger and double array -> R numeric vector
as_r('[1, 2.0, "3"]')   # JSON mixed array -> R list
as_r('[1, 2147483648]') # JSON integer > R integer max -> R numeric vector

json <- '{"b": 1, "a": ["c", "d"], "e": true, "f": [true], "g": {}}'
as_r(json) |> str()     # parsing complex objects
identical(              # JSON scalar and length 1 array identical in R
    as_r('{"a": 1}'), as_r('{"a": [1]}')
)

}
