#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>

#include "enum_index.h"
#include "rquerypivot.h"

#include <cpp11/sexp.hpp>
#include <cpp11/protect.hpp> // 'stop'

using namespace jsoncons;

[[cpp11::register]]
sexp cpp_j_flatten(
    const std::vector<std::string>& data, const std::string& data_type,
    const std::string& object_names, const std::string& as,
    const std::string& path, const std::string& path_type)
{
    sexp result;
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: {
        result =
            rquerypivot<ojson>(path, as, data_type, path_type, false).
            flatten(data);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, false).
            flatten(data);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}

[[cpp11::register]]
sexp cpp_j_flatten_con(
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
            flatten(con, n_records);
        break;
    }
    case object_names::sort: {
        result =
            rquerypivot<json>(path, as, data_type, path_type, verbose).
            flatten(con, n_records);
        break;
    }
    default: {
        cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }}

    return result;
}
