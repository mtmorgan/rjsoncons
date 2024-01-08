#include "cpp11/declarations.hpp"

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>

#include "as_r.h"
#include "j_pivot.h"

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
Json j_query_eval(Json j, const std::string path, const std::string path_type)
{
    // evaluate path
    switch(hash(path_type.c_str())) {
    case hash("JSONpointer"): return jsonpointer::get<Json>(j, path);
    case hash("JSONpath"): return jsonpath::json_query<Json>(j, path);
    case hash("JMESpath"): return jmespath::search<Json>(j, path);
    default: cpp11::stop("unknown `path_type` = '" + path_type + "'");
    }
}

template<class Json>
sexp j_query_impl(
    const std::string data, const std::string path,
    const std::string as, const std::string path_type)
{
    Json j = Json::parse(data);
    Json result = j_query_eval<Json>(j, path, path_type);
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
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

// pivot

template<class Json>
sexp j_pivot_impl(
    const std::string data, const std::string path,
    const std::string as, const std::string path_type)
{
    Json j = Json::parse(data);
    Json query = j_query_eval<Json>(j, path, path_type);
    Json pivot = j_pivot<Json>(query);
    return json_as(pivot, as);
}

[[cpp11::register]]
sexp cpp_j_pivot(
    const std::string data, const std::string path,
    const std::string object_names, const std::string as,
    const std::string path_type)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"): return j_pivot_impl<ojson>(data, path, as, path_type);
    case hash("sort"): return j_pivot_impl<json>(data, path, as, path_type);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
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

// ndjson_query

template<class Json>
cpp11::list ndjson_query_impl(
    const std::vector<std::string> data, const std::string path,
    const std::string as, const std::string path_type)
{
    cpp11::writable::list parsed(data.size());
    for (auto datum : data) {
        sexp result = j_query_impl<Json>(datum, path, as, path_type);
        parsed.push_back(result);
    }

    return parsed;
}

[[cpp11::register]]
cpp11::list cpp_ndjson_query(
    const std::vector<std::string> data, const std::string path,
    const std::string object_names, const std::string as,
    const std::string path_type)
{
    switch(hash(object_names.c_str())) {
    case hash("asis"):
        return ndjson_query_impl<ojson>(data, path, as, path_type);
    case hash("sort"):
        return ndjson_query_impl<json>(data, path, as, path_type);
    default: cpp11::stop("unknown `object_names = '" + object_names + "'`");
    }
}

