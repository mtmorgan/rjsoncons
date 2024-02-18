#include <cpp11/declarations.hpp>

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>

#include "utilities.h"
#include "readbinbuf.h"
#include "raw_buffer.h"
#include "j_as.h"
#include "r_json.h"

using namespace jsoncons;        // convenience
using namespace cpp11::literals; // _nm

auto readbinbuf::read_bin = cpp11::package("base")["readBin"];

[[cpp11::register]]
std::string cpp_version()
{
    versioning_info v = version();
    return
        std::to_string(v.major) + '.' +
        std::to_string(v.minor) + '.' +
        std::to_string(v.patch);
}

// as_r

[[cpp11::register]]
sexp cpp_as_r(
    std::vector<std::string> data, const std::string data_type,
    const std::string object_names)
{
    sexp result;

    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = r_json<ojson>(data_type).as_r(data);
        break;
    };
    case object_names::sort: {
        result = r_json<json>(data_type).as_r(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    };}

    return result;
}

[[cpp11::register]]
sexp cpp_as_r_con(
    const cpp11::sexp& con, const std::string data_type,
    const std::string object_names,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = r_json<ojson>(data_type).as_r(con, n_records, verbose);
        break;
    }
    case object_names::sort: {
        result = r_json<json>(data_type).as_r(con, n_records, verbose);
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
    const std::vector<std::string> data, const std::string data_type,
    const std::string object_names, const std::string as,
    const std::string path, const std::string path_type)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = r_json<ojson>(path, as, data_type, path_type).query(data);
        break;
    }
    case object_names::sort: {
        result = r_json<json>(path, as, data_type, path_type).query(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_j_query_con(
    const cpp11::sexp& con, const std::string data_type,
    const std::string object_names, const std::string as,
    const std::string path, const std::string path_type,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            r_json<ojson>(path, as, data_type, path_type).
            query(con, n_records, verbose);
        break;
    }
    case object_names::sort: {
        result =
            r_json<json>(path, as, data_type, path_type).
            query(con, n_records, verbose);
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
    const std::vector<std::string> data, const std::string data_type,
    const std::string object_names, const std::string as,
    const std::string path, const std::string path_type)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result = r_json<ojson>(path, as, data_type, path_type).pivot(data);
        break;
    }
    case object_names::sort: {
        result = r_json<json>(path, as, data_type, path_type).pivot(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_j_pivot_con(
    const cpp11::sexp& con, const std::string data_type,
    const std::string object_names, const std::string as,
    const std::string path, const std::string path_type,
    const double n_records, const bool verbose)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            r_json<ojson>(path, as, data_type, path_type).
            pivot(con, n_records, verbose);
        break;
    }
    case object_names::sort: {
        result =
            r_json<json>(path, as, data_type, path_type).
            pivot(con, n_records, verbose);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}
