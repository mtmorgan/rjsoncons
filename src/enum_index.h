#ifndef RJSONCONS_ENUM_INDEX_H
#define RJSONCONS_ENUM_INDEX_H

#include <string>
#include <map>

#include <cpp11/protect.hpp>

namespace rjsoncons {           // enums

    enum data_type { json_data_type, ndjson_data_type };
    enum object_names { asis, sort };
    enum as { string, R };
    enum path_type { JSONpointer, JSONpath, JMESpath };

    static std::map<std::string, data_type> data_type_map {
        {"json", json_data_type}, {"ndjson", ndjson_data_type}
    };

    static std::map<std::string, object_names> object_names_map {
        {"asis", asis}, {"sort", sort}
    };
    
    static std::map<std::string, as> as_map {
        {"string", string}, {"R", R}
    };

    static std::map<std::string, path_type> path_type_map {
        {"JSONpointer", JSONpointer}, {"JSONpath", JSONpath},
        {"JMESpath", JMESpath}
    };

    // look up 'key' in 'enum_map', returning index; used to translate
    // R string to enum value.
    template<class T>
    T enum_index(
        const std::map<std::string, T>& enum_map, const std::string& key)
    {
        auto value = enum_map.find(key);
        if (value == std::end(enum_map)) {
            cpp11::stop("'" + key + "' unknown");
        }

        return value->second;
    }

}

#endif
