#include <cpp11/declarations.hpp>

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>

#include "utilities.h"
#include "j_as.h"
#include "j_query.h"
#include "j_pivot.h"
#include "r_json.h"

using namespace jsoncons; // for convenience

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
sexp cpp_as_r(std::string data, std::string jtype)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return as_r_impl<ojson>(data);
    case hash("sort"): return as_r_impl<json>(data);
    default: cpp11::stop("unknown `object_names = '" + jtype + "'`");
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
    switch(hash(object_names.c_str())) {
    case hash("asis"): return r_json_init<ojson>(path, as, data_type, path_type);
    case hash("sort"): return r_json_init<json>(path, as, data_type, path_type);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

[[cpp11::register]]
void cpp_r_json_query(
    sexp ext,
    const std::vector<std::string> data,
    const std::string object_names)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"): { r_json_query<ojson>(ext, data); break; }
    case hash("sort"): { r_json_query<json>(ext, data); break; }
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

[[cpp11::register]]
void cpp_r_json_pivot(
    sexp ext,
    const std::vector<std::string> data,
    const std::string object_names)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"): { r_json_pivot<ojson>(ext, data); break; }
    case hash("sort"): { r_json_pivot<json>(ext, data); break; }
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

[[cpp11::register]]
cpp11::sexp cpp_r_json_finish(sexp ext, const std::string object_names)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"): return r_json_finish<ojson>(ext);
    case hash("sort"): return r_json_finish<json>(ext);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}
