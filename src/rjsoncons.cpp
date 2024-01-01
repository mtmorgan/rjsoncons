#include "cpp11/declarations.hpp"

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>

#include "as_r.h"
#include "jsonpivot.h"

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

// use this to switch() on string values
// https://stackoverflow.com/a/46711735/547331
constexpr unsigned int hash(const char *s, int off = 0)
{
    return !s[off] ? 5381 : (hash(s, off+1)*33) ^ s[off];
}

// result type

template<class Json>
sexp json_as(Json j, std::string as)
{
    switch(hash(as.c_str())) {
    case hash("string"): return as_sexp( j.template as<std::string>() );
    case hash("R"): return as_r<Json>(j);
    default: cpp11::stop("unknown `as = '" + as + "'`");
    }
}

// query

template<class Json>
sexp j_query_impl(
    const std::string data, const std::string path,
    const std::string as, const std::string path_type)
{
    // parse data
    Json j = Json::parse(data);

    // evaluate path
    Json result;
    switch(hash(path_type.c_str())) {
    case hash("JSONpointer"): {
        result = jsonpointer::get<Json>(j, path);
        break;
    }
    case hash("JSONpath"): {
        result = jsonpath::json_query<Json>(j, path);
        break;
    }
    case hash("JMESpath"): {
        result = jmespath::search<Json>(j, path);
        break;
    }
    default: cpp11::stop("unknown `path_type` = '" + path_type + "'");
    }

    // translate result
    return json_as(result, as);
}

[[cpp11::register]]
sexp cpp_j_query(
    const std::string data, const std::string path,
    const std::string object_names, const std::string as,
    const std::string path_type)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"): return j_query_impl<ojson>(data, path, as, path_type);
    case hash("sort"): return j_query_impl<json>(data, path, as, path_type);
    default: cpp11::stop("unknown `object_names` = '" + object_names + "'");
    }
}

// pivot

template<class Json>
sexp j_pivot_impl(const std::string data, const std::string as)
{
    Json j = Json::parse(data);
    Json result = j_pivot<Json>(j);
    return json_as(result, as);
}

[[cpp11::register]]
sexp cpp_j_pivot(std::string data, std::string jtype, std::string as)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return j_pivot_impl<ojson>(data, as);
    case hash("sort"): return j_pivot_impl<json>(data, as);
    default: cpp11::stop("unknown `object_names` = '" + jtype + "'`");
    }
}

// as_r

template<class Json>
sexp as_r_impl(const std::string data)
{
    Json j = Json::parse(data);
    return as_r<Json>(j);
}

[[cpp11::register]]
sexp cpp_as_r(std::string data, std::string jtype)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return as_r_impl<ojson>(data);
    case hash("sort"): return as_r_impl<json>(data);
    default: cpp11::stop("unknown `object_names = '" + jtype + "'`");
    }
}
