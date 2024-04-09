#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonschema/jsonschema.hpp>

#include "readbinbuf.h"
#include "j_as.h"

#include <cpp11/as.hpp>
#include <cpp11/sexp.hpp>
#include <cpp11/protect.hpp> // 'stop'

using namespace jsoncons;
using namespace rjsoncons;

template<class Json>
Json sexp_to_json(const sexp& data)
{
    if (Rf_isString(data)) {
        const std::string& data_string = as_cpp<const std::string&>(data);
        return Json::parse(data_string);
    } else {
        readbinbuf cbuf(data);
        std::istream is(&cbuf);
        return Json::parse(is);
    }
}

[[cpp11::register]]
bool cpp_j_schema_is_valid(
    const sexp& data,
    const sexp& schema)
{
    const auto data_ = sexp_to_json<ojson>(data);
    const auto schema_ = sexp_to_json<ojson>(schema);
    const auto compiled = jsonschema::make_json_schema(schema_);

    return compiled.is_valid(data_);
}

[[cpp11::register]]
sexp cpp_j_schema_validate(
    const sexp& data,
    const sexp& schema,
    const std::string& as)
{
    const auto data_ = sexp_to_json<ojson>(data);
    const auto schema_ = sexp_to_json<ojson>(schema);
    const auto compiled = jsonschema::make_json_schema(schema_);

    json_decoder<ojson> decoder;
    compiled.validate(data_, decoder);
    const ojson output = decoder.get_result();

    return j_as(output, as);
}
