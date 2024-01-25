#include <cpp11/declarations.hpp>

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>

#include "utilities.h"
#include "raw_buffer.h"
#include "j_as.h"
#include "r_json.h"

using namespace jsoncons;        // convenience
using namespace cpp11::literals; // _nm

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
sexp cpp_as_r(std::string data, const std::string object_names)
{
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: return as_r_impl<ojson>(data);
    case object_names::sort: return as_r_impl<json>(data);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

// r_json

[[cpp11::register]]
sexp cpp_r_json_init(
    const std::string object_names,
    const std::string path,
    const std::string as,
    const std::string data_type,
    const std::string path_type
    )
{
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis:
        return r_json_init<ojson>(path, as, data_type, path_type);
    case object_names::sort:
        return r_json_init<json>(path, as, data_type, path_type);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

[[cpp11::register]]
void cpp_r_json_query(
    sexp ext,
    const std::vector<std::string> data,
    const std::string object_names)
{
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: { r_json_query<ojson>(ext, data); break; }
    case object_names::sort: { r_json_query<json>(ext, data); break; }
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

[[cpp11::register]]
void cpp_r_json_pivot(
    sexp ext,
    const std::vector<std::string> data,
    const std::string object_names)
{
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: { r_json_pivot<ojson>(ext, data); break; }
    case object_names::sort: { r_json_pivot<json>(ext, data); break; }
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

// 'raw' versions of query and pivot

[[cpp11::register]]
cpp11::list cpp_r_json_query_raw(
    sexp ext,
    raws prefix, raws bin, int n_records,
    const std::string object_names)
{
    rjsoncons::raw_buffer buffer(prefix, bin, n_records);
    const std::vector<std::string> data = buffer.to_strings();
    cpp_r_json_query(ext, data, object_names);

    return cpp11::list({
            "prefix"_nm = buffer.remainder(),
            "n_lines"_nm = data.size()
        });
}

[[cpp11::register]]
cpp11::list cpp_r_json_pivot_raw(
    sexp ext,
    const raws prefix, const raws bin, int n_records,
    const std::string object_names)
{
    rjsoncons::raw_buffer buffer(prefix, bin, n_records);
    const std::vector<std::string> data = buffer.to_strings();
    cpp_r_json_pivot(ext, data, object_names);

    return cpp11::list({
            "prefix"_nm = buffer.remainder(),
            "n_lines"_nm = data.size()
        });
}

[[cpp11::register]]
cpp11::sexp cpp_r_json_finish(sexp ext, const std::string object_names)
{
    switch(enum_index(object_names_map, object_names)) {
    case object_names::asis: return r_json_finish<ojson>(ext);
    case object_names::sort: return r_json_finish<json>(ext);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}
