#ifndef RJSONCONS_J_QUERY_H
#define RJSONCONS_J_QUERY_H

#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>
#include <cpp11.hpp>

template<class Json>
Json j_query(Json j, const std::string path, const std::string path_type)
{
    // evaluate path
    switch(hash(path_type.c_str())) {
    case hash("JSONpointer"): return jsonpointer::get<Json>(j, path);
    case hash("JSONpath"): return jsonpath::json_query<Json>(j, path);
    case hash("JMESpath"): return jmespath::search<Json>(j, path);
    default: cpp11::stop("unknown `path_type` = '" + path_type + "'");
    }
}

#endif
