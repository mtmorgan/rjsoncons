#ifndef RJSONCONS_JSONPIVOT_H
#define RJSONCONS_JSONPIVOT_H

#include <cpp11/declarations.hpp>
#include <jsoncons/json.hpp>

template<class Json>
std::vector<std::string> object_all_keys(const Json j)
{
    // 'keys' returns keys in the order they are discoverd, 'seen' is
    // used as a filter to only insert unseen keys
    std::vector<std::string> keys;
    std::unordered_set<std::string> seen;

    // visit each element in the array...
    for (const auto& elt : j.array_range()) {
        // if it's an object...
        if (elt.type() != json_type::object_value)
            continue;
        // ...collect member (key) names that have not yet been seen
        for (const auto& member : elt.object_range())
            if (seen.insert(member.key()).second)
                keys.push_back(member.key());
    }

    return keys;
}

template<class Json>
Json pivot_array_as_object(const Json j)
{
    Json object(json_object_arg);
    std::vector<std::string> keys = object_all_keys(j);

    // initialize
    for (const auto& key : keys)
        object[key] = Json(json_array_arg);

    // pivot
    for (const auto& elt : j.array_range()) {
        for (const auto& key : keys) {
            // non-object values or missing elements are assigned 'null'
            Json value = Json::null();
            if (elt.type() == json_type::object_value)
                value = elt.at_or_null(key);
            object[key].push_back(value);
        }
    }

    return object;
}

template<class Json>
Json jsonpivot(const Json j)
{
    Json value;

    switch(j.type()) {
    case json_type::null_value: {
        value = j;
        break;
    };
    case json_type::array_value: {
        value = pivot_array_as_object(j);
        break;
    };
    default: cpp11::stop("`jsonpivot()` 'data' must be a JSON array");
    };

    return value;
}

#endif
