#ifndef RJSONCONS_J_AS_HPP
#define RJSONCONS_J_AS_HPP

#include <numeric>
#include <jsoncons/json.hpp>

using namespace jsoncons;

#include "enum_index.h"
using namespace rjsoncons;

#include <cpp11/list.hpp>
#include <cpp11/logicals.hpp>
#include <cpp11/integers.hpp>
#include <cpp11/doubles.hpp>
#include <cpp11/strings.hpp>
#include <cpp11/protect.hpp>    // stop

using namespace cpp11;

enum class r_type : uint8_t
{
    null_value,
    logical_value,
    integer_value,
    numeric_value,
    character_value,
    vector_value,
    list_value
};

template<class Int64_t>
bool is_integer(Int64_t int64_value)
{
    // can a 64-bit signed or unsigned int be represented as (signed)
    // int32_t?  'volatile' writes data to avoid compiler
    // 'optimization' that would short-circuit the test
    volatile auto int32_value = static_cast<int32_t>(int64_value);
    return
        int32_value != R_NaInt &&
        static_cast<Int64_t>(int32_value) == int64_value;
}

template<class Json>
r_type r_atomic_type(const Json j)
{
    r_type rtype;

    switch(j.type()) {
    case json_type::null_value: {
        rtype = r_type::null_value;
        break;
    }
    case json_type::bool_value: {
        rtype = r_type::logical_value;
        break;
    }
    case json_type::int64_value: {
        rtype = is_integer(j.template as<int64_t>()) ?
            r_type::integer_value : r_type::numeric_value;
        break;
    }
    case json_type::uint64_value: {
        rtype = is_integer(j.template as<uint64_t>()) ?
            r_type::integer_value : r_type::numeric_value;
        break;
    }
    case json_type::double_value: {
        rtype = r_type::numeric_value;
        break;
    }
    case json_type::string_value: {
        rtype = r_type::character_value;
        break;
    }
    case json_type::array_value: {
        rtype = r_type::vector_value;
        break;
    }
    case json_type::object_value: {
        rtype = r_type::list_value;
        break;
    }
    default: {
        cpp11::stop("unhandled JSON type");
    }}

    return rtype;
}

template<class Json>
r_type r_vector_type(const Json j)
{
    r_type t;

    auto array_type = [](r_type t, const Json j) {
        r_type rt = r_atomic_type(j);

        // promotions
        if (t != rt) {
            if (t > rt) {
                // simplify comparisons by ordering low to high
                std::swap(t, rt);
            }
            if (t == r_type::integer_value) { // 'number'
                bool is_number =
                    rt == r_type::integer_value || rt == r_type::numeric_value;
                if (is_number) {
                    t = rt;
                } else {
                    t = r_type::list_value;
                }
            } else {
                // heterogenous elements, store as object
                t = r_type::list_value;
            }
        }

        return t;
    };

    if (j.size() == 0) {
        t = r_type::null_value;
    } else {
        auto r = j.array_range();
        t = std::accumulate(
            r.cbegin(), r.cend(), r_atomic_type(j[0]),
            array_type);
    }

    return t;
}

template<class Json, class cpp11_t, class json_t>
sexp j_as_r_vector(const Json j)
{
    cpp11_t value(j.size());
    std::transform(
        j.array_range().cbegin(), j.array_range().cend(), value.begin(),
        [](const Json j_elt) { return j_elt.template as<json_t>(); });
    return value;
}

template<class Json>
sexp j_as_r(const Json j)
{
    sexp result;
    const r_type rtype = r_atomic_type(j);

    switch(rtype) {
    case r_type::null_value: {
        result = R_NilValue;
        break;
    }
    case r_type::logical_value: {
        result = logicals({ j.template as<bool>() });
        break;
    }
    case r_type::integer_value: {
        result = as_sexp( j.template as<int32_t>() );
        break;
    }
    case r_type::numeric_value: {
        result = as_sexp( j.template as<double>() );
        break;
    }
    case r_type::character_value: {
        result = as_sexp( j.template as<std::string>() );
        break;
    }
    case r_type::vector_value: {
        const r_type member_type = r_vector_type(j);
        switch(member_type) {
        case r_type::null_value: {
            result = writable::list(j.size()); // default: NULL elements
            break;
        }
        case r_type::logical_value: {
            result = j_as_r_vector<Json, writable::logicals, bool>(j);
            break;
        }
        case r_type::integer_value: {
            result = j_as_r_vector<Json, writable::integers, int32_t>(j);
            break;
        }
        case r_type::numeric_value: {
            result = j_as_r_vector<Json, writable::doubles, double>(j);
            break;
        }
        case r_type::character_value: {
            result = j_as_r_vector<Json, writable::strings, std::string>(j);
            break;
        }
        case r_type::vector_value:
        case r_type::list_value: {
            const writable::list value(j.size());
            std::transform(
                j.array_range().cbegin(), j.array_range().cend(), value.begin(),
                [](const Json j_elt) { return j_as_r(j_elt); });
            result = value;
            break;
        }}
        break;                  // r_type::vector_value
    }
    case r_type::list_value: {
        const writable::list value(j.size());
        const writable::strings names(j.size());
        auto range = j.object_range();

        int i = 0;
        for (auto it = range.cbegin(); it != range.cend(); ++it, ++i) {
            names[i] = it->key();
            value[i] = j_as_r(it->value());
        }

        value.names() = names;
        result = value;
        break;
    }}

    return result;
}

// json to R

template<class Json>
sexp j_as(Json j, rjsoncons::as as)
{
    switch(as) {
    case as::string: return as_sexp( j.template as<std::string>() );
    case as::R: return j_as_r<Json>(j);
    default: cpp11::stop("`as_r()` unknown `as = `");
    }
}

template<class Json>
sexp j_as(Json j, const std::string& as)
{
    return j_as(j, enum_index(as_map, as));
}

#endif
