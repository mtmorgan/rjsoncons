#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>

#include "enum_index.h"
#include "readbinbuf.h"
#include "rquerypivot.h"

#include <cpp11/function.hpp>   // includes 'package'
#include <cpp11/sexp.hpp>
#include <cpp11/protect.hpp>    // 'stop'

using namespace jsoncons;       // convenience

function readbinbuf::read_bin = cpp11::package("base")["readBin"];

[[cpp11::register]]
std::string cpp_version()
{
    const versioning_info v = version();
    return
        std::to_string(v.major) + '.' +
        std::to_string(v.minor) + '.' +
        std::to_string(v.patch);
}

// as_r

[[cpp11::register]]
sexp cpp_as_r(
    const std::vector<std::string>& data, const std::string& data_type,
    const std::string& object_names)
{
    sexp result;

    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = rquerypivot<ojson>(data_type, false).as_r(data);
        break;
    }
    case object_names::sort: {
        result = rquerypivot<json>(data_type, false).as_r(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_as_r_con(
    const sexp& con, const std::string& data_type,
    const std::string& object_names,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = rquerypivot<ojson>(data_type, verbose).as_r(con, n_records);
        break;
    }
    case object_names::sort: {
        result = rquerypivot<json>(data_type, verbose).as_r(con, n_records);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

// j_query

[[cpp11::register]]
sexp cpp_j_query(
    const std::vector<std::string>& data, const std::string& data_type,
    const std::string& object_names, const std::string& as,
    const std::string& path, const std::string& path_type)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            rquerypivot<ojson>(path, as, data_type, path_type, false).
            query(data);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, false).
            query(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_j_query_con(
    const sexp& con, const std::string& data_type,
    const std::string& object_names, const std::string& as,
    const std::string& path, const std::string& path_type,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            rquerypivot<ojson>(path, as, data_type, path_type, verbose).
            query(con, n_records);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, verbose).
            query(con, n_records);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

// j_pivot

[[cpp11::register]]
sexp cpp_j_pivot(
    const std::vector<std::string>& data, const std::string& data_type,
    const std::string& object_names, const std::string& as,
    const std::string& path, const std::string& path_type)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            rquerypivot<ojson>(path, as, data_type, path_type, false).
            pivot(data);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, false).
            pivot(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_j_pivot_con(
    const sexp& con, const std::string& data_type,
    const std::string& object_names, const std::string& as,
    const std::string& path, const std::string& path_type,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            rquerypivot<ojson>(path, as, data_type, path_type, verbose).
            pivot(con, n_records);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, verbose).
            pivot(con, n_records);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}
