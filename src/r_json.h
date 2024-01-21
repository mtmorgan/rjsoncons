#ifndef RJSONCONS_R_JSON_HPP
#define RJSONCONS_R_JSON_HPP

#include <jsoncons/json.hpp>
#include <cpp11.hpp>

#include "utilities.h"
#include "j_as.h"
#include "j_query.h"

using namespace cpp11;
using namespace jsoncons;

template<class Json>
class r_json
{
    // FIXME: as_, data_type_, path_type_ should be enums
    const std::string path_,
        as_,                    // string, R
        data_type_,             // json, ndjson
        path_type_;             // JSONpointer, JSONpath, JMESpath
    std::vector<Json> result_;

public:
    r_json() noexcept = default;

    r_json(std::string path, std::string as, std::string data_type,
           std::string path_type)
        : path_(path), as_(as), data_type_(data_type), path_type_(path_type)
        {};

    void query(const std::vector<std::string> data)
        {
            result_.reserve(result_.size() + data.size());
            std::transform(
                data.begin(), data.end(), std::back_inserter(result_),
                [&](const std::string datum) {
                    Json j = Json::parse(datum);
                    return j_query<Json>(j, path_, path_type_);
                });
        }

    void pivot_append_result(Json j)
        {
            if (j.type() == json_type::null_value) {
                // 'null' is treated as '{}'
                j = Json(json_object_arg);
            }

            // all members of 'j' need to be JSON array
            for (auto& member: j.object_range()) {
                auto key = member.key();
                if (member.value().type() != json_type::array_value) {
                    Json ja = Json::make_array(1, j[key]);
                    j[key].swap(ja);
                }
            }
            // FIXME: check intersection of keys in result_[0], j

            if (result_.size() == 0) {
                // first pivot - insert (even '{}') & exit
                result_.push_back(j);
                return;
            } else if (result_.size() == 1 && result_[0].size() == 0) {
                // first pivot was '{}' -- replace with current
                result_[0] = j;
                return;
            } else if (j.size() == 0) {
                // filter empty pivots
                return;
            }

            // insert j.member after result_[0].member
            for (auto& member : result_[0].object_range()) {
                auto j_range = j[member.key()].array_range();
                auto& m = member.value();
                m.insert(m.array_range().end(), j_range.begin(), j_range.end());
            }
        }

    void pivot(const std::vector<std::string> data)
        {
            // collect queries across all data
            for (const auto& datum: data) {
                Json j = Json::parse(datum);
                // query and pivot
                Json q = j_query<Json>(j, path_, path_type_);
                Json p = j_pivot<Json>(q);
                // append to result
                pivot_append_result(p);
            }
        }

    cpp11::sexp as() const
        {
            cpp11::writable::list result(result_.size());
            std::transform(
                result_.begin(), result_.end(), result.begin(),
                [&](Json j) { return j_as(j, as_); });

            // FIXME: should be able to create cpp11::strings directly
            return as_ == "string" ?
                package("base")["unlist"](result) :
                result;
        }
};

// R interface

template<class Json>
sexp r_json_init(
    const std::string path, const std::string as, const std::string data_type,
    const std::string path_type)
{
    r_json<Json> *ndj = new r_json<Json>(path, as, data_type, path_type);
    external_pointer< r_json<Json> > extp(ndj);
    return as_sexp(extp);
}

template<class Json>
void r_json_query(sexp ext, const std::vector<std::string> data)
{
    external_pointer< r_json<Json> > extp(ext);
    extp->query(data);
}

template<class Json>
void r_json_pivot(sexp ext, const std::vector<std::string> data)
{
    external_pointer< r_json<Json> > extp(ext);
    extp->pivot(data);
}

template<class Json>
cpp11::sexp r_json_finish(sexp ext)
{
    external_pointer< r_json<Json> > extp(ext);
    cpp11::sexp result = extp->as();
    delete extp.release();
    return result;
}

#endif
