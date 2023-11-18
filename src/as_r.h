#ifndef RJSONCONS_AS_R_HPP
#define RJSONCONS_AS_R_HPP

#include <cpp11/declarations.hpp>
#include <jsoncons/json.hpp>
#include <numeric>

using namespace jsoncons;

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

template<class Int_t>
bool is_integer(Int_t int64_value)
{
    // can a 64-bit signed or unsigned int be represented as (signed)
    // int32_t?  'volatile' writes data to avoid compiler
    // 'optimization' that would short-circuit the test
    volatile int32_t int32_value = static_cast<int32_t>(int64_value);
    return
        int32_value != R_NaInt &&
        static_cast<int64_t>(int32_value) == int64_value;
}

template<class Json>
r_type r_atomic_type(Json j)
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
    case json_type::half_value: {
        cpp11::stop("unhandled JSON type 'half_value'");
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
    case json_type::byte_string_value: {
        cpp11::stop("unhandled JSON type 'byte_string_value'");
        break;
    }
    case json_type::array_value: {
        rtype = r_type::vector_value;
        break;
    }
    case json_type::object_value: {
        rtype = r_type::list_value;
        break;
    }}

    return rtype;
}

template<class Json>
r_type r_vector_type(Json j)
{
    r_type t;

    auto array_type = [](r_type t, Json j) {
        r_type jt = r_atomic_type(j);

        // promotions
        if (t != jt) {
            if (t > jt)         // simplify comparisons by ordering low to high
                std::swap(t, jt);
            if (t == r_type::integer_value) { // 'number'
                bool is_number =
                    jt == r_type::integer_value || jt == r_type::numeric_value;
                if (is_number) {
                    t = jt;
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
        t = std::accumulate(r.begin(), r.end(), r_atomic_type(j[0]), array_type);
    }

    return t;
}

template<class cpp11_t, class json_t, class Json>
sexp as_r_vector(Json j)
{
    cpp11_t value(j.size());
    for (int i = 0; i < j.size(); ++i)
        value[i] = j[i].template as<json_t>();
    return value;
}

template<class Json>
sexp as_r(Json j)
{
    sexp result;
    r_type rtype = r_atomic_type(j);

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
        r_type member_type = r_vector_type(j);
        switch(member_type) {
        case r_type::null_value: {
            result = writable::list(j.size()); // default: NULL elements
            break;
        }
        case r_type::logical_value: {
            result = as_r_vector<writable::logicals, bool>(j);
            break;
        }
        case r_type::integer_value: {
            result = as_r_vector<writable::integers, int32_t>(j);
            break;
        }
        case r_type::numeric_value: {
            result = as_r_vector<writable::doubles, double>(j);
            break;
        }
        case r_type::character_value: {
            result = as_r_vector<writable::strings, std::string>(j);
            break;
        }
        case r_type::vector_value:
        case r_type::list_value: {
            writable::list value(j.size());
            for (int i = 0; i < j.size(); ++i)
                value[i] = as_r(j[i]);
            result = value;
            break;
        }}
        break;                  // r_type::vector_value
    }
    case r_type::list_value: {
        writable::list value(j.size());
        writable::strings names(j.size());
        auto range = j.object_range();

        int i = 0;
        for (auto it = range.begin(); it != range.end(); ++it, ++i) {
            names[i] = it->key();
            value[i] = as_r(it->value());
        }

        value.names() = names;
        result = value;
        break;
    }}

    return result;
}

#endif
