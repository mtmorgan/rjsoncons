#include "cpp11/declarations.hpp"

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>

#include "as_r.h"

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

// jsonpath

template<class Json>
sexp jsonpath_impl(
    const std::string data, const std::string path,
    const std::string as)
{
    Json j = Json::parse(data);
    Json result = jsonpath::json_query<Json>(j, path);
    return json_as(result, as);
}

[[cpp11::register]]
sexp cpp_jsonpath(
    std::string data, std::string path, std::string jtype, std::string as)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return jsonpath_impl<ojson>(data, path, as);
    case hash("sort"): return jsonpath_impl<json>(data, path, as);
    default: cpp11::stop("unknown `object_names = '" + jtype + "'`");
    }
}

// jmespath

template<class Json>
sexp jmespath_impl(
    const std::string data, const std::string path, const std::string as)
{
    Json j = Json::parse(data);
    Json result = jmespath::search<Json>(j, path);
    return json_as(result, as);
}

[[cpp11::register]]
sexp cpp_jmespath(
    std::string data, std::string path, std::string jtype, std::string as)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return jmespath_impl<ojson>(data, path, as);
    case hash("sort"): return jmespath_impl<json>(data, path, as);
    default: cpp11::stop("unknown `object_names = '" + jtype + "'`");
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
