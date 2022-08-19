#include "cpp11/declarations.hpp"

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>

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

// jsonpath

template<class Json>
std::string jsonpath_impl(const std::string data, const std::string path)
{
    Json j = Json::parse(data);
    Json result = jsonpath::json_query<Json>(j, path);
    return result.template as<std::string>();
}

[[cpp11::register]]
std::string cpp_jsonpath(std::string data, std::string path, std::string jtype)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return jsonpath_impl<ojson>(data, path);
    case hash("sort"): return jsonpath_impl<json>(data, path);
    default: cpp11::stop("unknown object_names '" + jtype + "'");
    }
}

// jmespath

template<class Json>
std::string jmespath_impl(const std::string data, const std::string path)
{
    Json j = Json::parse(data);
    Json result = jmespath::search<Json>(j, path);
    return result.template as<std::string>();
}

[[cpp11::register]]
std::string cpp_jmespath(std::string data, std::string path, std::string jtype)
{
    switch(hash(jtype.c_str())) {
    case hash("asis"): return jmespath_impl<ojson>(data, path);
    case hash("sort"): return jmespath_impl<json>(data, path);
    default: cpp11::stop("unknown object_names '" + jtype + "'");
    }
}
