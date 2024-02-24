#include <cpp11/declarations.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpatch/jsonpatch.hpp>

#include "enum_index.h"
#include "j_as.h"

using namespace jsoncons;
using namespace cpp11;

[[cpp11::register]]
sexp cpp_j_patch_apply(
    const std::string& data, const std::string& data_type,
    const std::string& patch, const std::string& as)
{
    ojson data_ = ojson::parse(data);
    ojson patch_ = ojson::parse(patch);
    jsonpatch::apply_patch(data_, patch_);
    return j_as(data_, enum_index(as_map, as));
}

[[cpp11::register]]
sexp cpp_j_patch_from(
    const std::string& data_x, const std::string& data_type_x,
    const std::string& data_y, const std::string& data_type_y,
    const std::string& as)
{
    ojson data_x_ = ojson::parse(data_x);
    ojson data_y_ = ojson::parse(data_y);
    auto patch = jsonpatch::from_diff(data_x_, data_y_);
    return j_as(patch, enum_index(as_map, as));
}
