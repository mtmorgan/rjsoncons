#ifndef RJSONCONS_R_JSON_HPP
#define RJSONCONS_R_JSON_HPP

#include <jsoncons/json.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>
#include <cpp11.hpp>

#include "utilities.h"
#include "readbinbuf.h"
#include "j_as.h"

using namespace cpp11;
using namespace jsoncons;
using namespace rjsoncons;

template<class Json>
class r_json
{
    rjsoncons::as as_;
    rjsoncons::data_type data_type_;
    rjsoncons::path_type path_type_;
    std::vector<Json> result_;
    // only one of the following will be valid per instance
    jmespath::jmespath_expression<Json> jmespath_;
    jsonpath::jsonpath_expression<Json> jsonpath_;
    const std::string jsonpointer_;

    // pivot implementation

    std::vector<std::string> all_keys(const Json j)
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

    Json pivot_array_as_object(const Json j)
        {
            Json object(json_object_arg);
            std::vector<std::string> keys = all_keys(j);

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

    Json pivot_one(const Json j)
        {
            Json value;

            switch(j.type()) {
            case json_type::null_value: {
                value = j;
                break;
            }
            case json_type::object_value: {
                // optimistically assuming that this is already an
                // object-of-arrays
                value = j;
                break;
            }
            case json_type::array_value: {
                value = pivot_array_as_object(j);
                break;
            }
            default:
                cpp11::stop("`j_pivot()` 'path' must yield an object or array");
            };

            // a Json object-of-arrays
            return value;
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

public:
    r_json() noexcept = default;

    r_json(std::string data_type)
        : as_(as::R),
          data_type_(enum_index(data_type_map, data_type)),
          path_type_(path_type::JSONpointer),
          jmespath_(jmespath::make_expression<Json>("@")),
          jsonpath_(jsonpath::make_expression<Json>("$")),
          jsonpointer_("/")
        {}

    r_json(std::string path, std::string as, std::string data_type,
           std::string path_type)
        : as_(enum_index(as_map, as)),
          data_type_(enum_index(data_type_map, data_type)),
          path_type_(enum_index(path_type_map, path_type)),
          // only one 'path' is used; initialize others to a default
          jmespath_(
              path_type_ == path_type::JMESpath ?
              jmespath::make_expression<Json>(path) :
              jmespath::make_expression<Json>("@")),
          jsonpath_(
              path_type_ == path_type::JSONpath ?
              jsonpath::make_expression<Json>(path) :
              jsonpath::make_expression<Json>("$")),
          jsonpointer_(path_type_ == path_type::JSONpointer ? path : "/")
        {}

    // as_r

    sexp as_r(const std::vector<std::string>& data)
        {
            result_.reserve(data.size());
            std::transform(
                data.begin(), data.end(), std::back_inserter(result_),
                [&](const std::string datum) { return Json::parse(datum); });

            return as();
        }

    sexp as_r(const cpp11::sexp& con, double n_records, bool verbose)
        {
            readbinbuf cbuf(con);
            std::istream is(&cbuf);

            switch(data_type_) {
            case data_type::json_data_type: {
                Json j = Json::parse(is);
                result_.push_back(j);
                break;
            };
            case data_type::ndjson_data_type: {
                json_decoder<Json> decoder;
                json_stream_reader reader(is, decoder);
                double n = 0;
                while (!reader.eof() && n < n_records) {
                    reader.read_next();
                    if (!reader.eof()) {
                        Json j = decoder.get_result();
                        result_.push_back(j);
                        n += 1;
                    }
                }
            };}

            return as();
        }

    // query

    Json query(Json j)
        {
            switch(path_type_) {
            case path_type::JSONpointer:
                return jsonpointer::get<Json>(j, jsonpointer_);
            case path_type::JSONpath: return jsonpath_.evaluate(j);
            case path_type::JMESpath: return jmespath_.evaluate(j);
            default: cpp11::stop("`j_query()` unknown 'path_type'");
            }
        }

    sexp query(const std::vector<std::string>& data)
        {
            // json_data_type has data.size() == 1
            result_.reserve(data.size());
            std::transform(
                data.begin(), data.end(), std::back_inserter(result_),
                [&](const std::string datum) {
                    Json j = Json::parse(datum);
                    return query(j);
                });

            return as();
        }

    sexp query(const cpp11::sexp& con, double n_records, bool verbose)
        {
            readbinbuf cbuf(con);
            std::istream is(&cbuf);

            switch(data_type_) {
            case data_type::json_data_type: {
                Json j = Json::parse(is);
                result_.push_back(query(j));
                break;
            };
            case data_type::ndjson_data_type: {
                json_decoder<Json> decoder;
                json_stream_reader reader(is, decoder);
                double n = 0;
                while (!reader.eof() && n < n_records) {
                    reader.read_next();
                    if (!reader.eof()) {
                        Json j = decoder.get_result();
                        result_.push_back(query(j));
                        n += 1;
                    }
                }
                break;
            };}

            return as();
        }

    // pivot

    void pivot(Json j)
        {
            // query and pivot
            Json q = query(j);
            Json p = pivot_one(q);
            // append to result
            pivot_append_result(p);
        }

    sexp pivot(const std::vector<std::string>& data)
        {
            // collect queries across all data
            for (const auto& datum: data) {
                Json j = Json::parse(datum);
                pivot(j);
            }

            return as();
        }

    sexp pivot(const cpp11::sexp& con, double n_records, bool verbose)
        {
            readbinbuf cbuf(con);
            std::istream is(&cbuf);

            switch(data_type_) {
            case data_type::json_data_type: {
                Json j = Json::parse(is);
                pivot(j);
                break;
            };
            case data_type::ndjson_data_type: {
                json_decoder<Json> decoder;
                json_stream_reader reader(is, decoder);
                double n = 0;
                while (!reader.eof() && n < n_records) {
                    reader.read_next();
                    if (!reader.eof()) {
                        Json j = decoder.get_result();
                        pivot(j);
                        n += 1;
                    }
                }
                break;
            };}
    
            return as();
        }

    // as

    sexp as() const
        {
            cpp11::writable::list result(result_.size());
            std::transform(
                result_.begin(), result_.end(), result.begin(),
                [&](Json j) { return j_as(j, as_); });

            return as_ == as::string ?
                package("base")["unlist"](result) : result;
        }
};

#endif
