#ifndef RJSONCONS_R_JSON_HPP
#define RJSONCONS_R_JSON_HPP

#include <algorithm>

#include <jsoncons/json.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>
#include <jsoncons_ext/jsonpath/jsonpath.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>

#include "readbinbuf.h"
#include "progressbar.h"
#include "j_as.h"

#include <cpp11/sexp.hpp>
#include <cpp11/list.hpp>
#include <cpp11/protect.hpp>    // 'stop'
#include <cpp11/function.hpp>   // 'package'

using namespace jsoncons;
using namespace rjsoncons;

template<class Json>
class rquerypivot
{
    const rjsoncons::as as_;
    const rjsoncons::data_type data_type_;
    const rjsoncons::path_type path_type_;
    // only one of the following will be valid per instance
    jmespath::jmespath_expression<Json> jmespath_;
    jsonpath::jsonpath_expression<Json> jsonpath_;
    const std::string jsonpointer_;

    bool verbose_;
    std::vector<Json> result_;

    // query implementation

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

    // pivot implementation

    std::vector<std::string> pivot_json_all_keys(const Json j)
        {
            // 'keys' returns keys in the order they are discoverd, 'seen' is
            // used as a filter to only insert unseen keys
            std::vector<std::string> keys;
            std::unordered_set<std::string> seen;

            // visit each element in the array...
            for (const auto& elt : j.array_range()) {
                // if it's an object...
                if (elt.type() != json_type::object_value) {
                    continue;
                }
                // ...collect member (key) names that have not yet been seen
                for (const auto& member : elt.object_range()) {
                    if (seen.insert(member.key()).second) {
                        keys.push_back(member.key());
                    }
                }
            }

            return keys;
        }

    Json pivot_json_array(const Json j)
        {
            Json object(json_object_arg);
            const std::vector<std::string> keys = pivot_json_all_keys(j);

            // initialize
            for (const auto& key : keys) {
                object[key] = Json(json_array_arg);
            }

            // pivot
            for (const auto& elt : j.array_range()) {
                for (const auto& key : keys) {
                    // non-object values or missing elements are assigned 'null'
                    Json value = Json::null();
                    if (elt.type() == json_type::object_value) {
                        value = elt.at_or_null(key);
                    }
                    object[key].push_back(value);
                }
            }

            return object;
        }

    void pivot_json(Json j)
        {
            switch(j.type()) {
            case json_type::null_value:
                 // 'null' is treated as '{}'
                j = Json(json_object_arg);
                break;
            case json_type::object_value: {
                // all members of 'j' need to be JSON array
                for (auto& member: j.object_range()) {
                    auto key = member.key();
                    if (member.value().type() != json_type::array_value) {
                        Json ja = Json::make_array(1, j[key]);
                        j[key].swap(ja);
                    }
                }
                break;
            }
            case json_type::array_value: {
                j = pivot_json_array(j);
                break;
            }
            default: {
                cpp11::stop("`j_pivot()` 'path' must yield an object or array");
            }}


            result_.push_back(j);
        }
        
    void pivot_ndjson(Json j)
        {
            if (j.type() == json_type::null_value) {
                // skip 'null' records
                return;
            }

            if (result_.size() == 0) {
                // result_.push_back(Json(json_object_arg));
                for (auto& member: j.object_range()) {
                    // all members of 'j' need to be JSON arrays
                    auto key = member.key();
                    Json ja = Json::make_array(1, j[key]);
                    j[key].swap(ja);
                }
                result_.push_back(j);
                return;
            }

            // insert j.member after result_[0].member. three cases:
            // result_[0] & j both have key, key only in result_[0],
            // key only in j

            // use unordered_set to keep track of key status in result_[0], j
            // fill j_keys; trim as each key from j is added to result_[0]
            std::unordered_set<std::string> j_keys;
            for (const auto& j_elt : j.object_range()) {
                j_keys.insert(j_elt.key());
            }

            // fill r_keys as each element discovered 'missing' from j
            std::unordered_set<std::string> r_keys;
            std::size_t n_r = 0; // # of elements in result_[0] before update
            for (auto& r_elt : result_[0].object_range()) {
                n_r = std::max(n_r, r_elt.value().size());
                // j contains result_[0].key...
                if (j_keys.find(r_elt.key()) == j_keys.end()) {
                    r_keys.insert(r_elt.key());
                    continue;
                }
                // insert j[r_elt.key()] after r_elt.value()
                const auto& j_elt = j[r_elt.key()];
                r_elt.value().push_back(j_elt);
                // remove key from 'j', leaving keys not in r
                j_keys.erase(r_elt.key());
            }

            // key only in result_[0] -- insert 'null'
            for (auto& r_key : r_keys) {
                result_[0][r_key].push_back(Json::null());
            }

            // key only in j
            if (j_keys.size()) {
                // construct array of n_r 'null' to pad each key
                Json pad(json_array_arg);
                pad.reserve(n_r);
                for (std::size_t i = 0; i < n_r; ++i)
                    pad.push_back(Json::null());
                for (auto& j_key : j_keys) {
                    // initialize key as empty array
                    result_[0][j_key] = pad;
                    result_[0][j_key].push_back(j[j_key]);
                }
            }
        }

    // flatten

    Json flatten(Json j)
        {
            switch(path_type_) {
            case path_type::JSONpointer: return jsonpointer::flatten(j);
            case path_type::JSONpath: return jsonpath::flatten(j);
            default: cpp11::stop("`j_flatten()` unsupported 'path_type'");
            }
        }

    // transformers for use in do_strings() / do_connection()
    void identity_transform(Json j)
        {
            result_.push_back(j);
        }


    void query_transform(Json j)
        {
            result_.push_back(query(j));
        }

    void pivot_transform(Json j)
        {
            Json q = query(j);
            if (data_type_ == data_type::json_data_type) {
                pivot_json(q);
            } else {
                pivot_ndjson(q);
            }
        }

    void flatten_transform(Json j)
        {
            result_.push_back(flatten(j));
        }

    // do_strings() / do_connection()
    sexp do_strings(
        const std::vector<std::string>& data,
        void (rquerypivot::*transform)(Json j))
        {
            result_.reserve(data.size());
            for (const auto& datum: data) {
                Json j = Json::parse(datum);
                (this->*transform)(j);
            }

            return as();
        }

    sexp do_connection(
        const sexp& con, double n_records,
        void (rquerypivot::*transform)(Json j))
        {
            readbinbuf cbuf(con);
            std::istream is(&cbuf);

            switch(data_type_) {
            case data_type::json_data_type: {
                Json j = Json::parse(is);
                (this->*transform)(j);
                break;
            }
            case data_type::ndjson_data_type: {
                progressbar progress("processing {cli::pb_current} records");
                json_decoder<Json> decoder;
                json_stream_reader reader(is, decoder);
                double n = 0;

                while (!reader.eof() && n < n_records) {
                    reader.read_next();
                    if (!reader.eof()) {
                        Json j = decoder.get_result();
                        (this->*transform)(j);
                        n += 1;
                        if (verbose_) {
                            progress.tick();
                        }
                    }
                }
            }}

            return as();
        }

public:
    rquerypivot() noexcept = default;

    rquerypivot(const std::string& data_type, bool verbose)
        : as_(as::R),
          data_type_(enum_index(data_type_map, data_type)),
          path_type_(path_type::JSONpointer),
          jmespath_(jmespath::make_expression<Json>("@")),
          jsonpath_(jsonpath::make_expression<Json>("$")),
          jsonpointer_("/"),
          verbose_(verbose)
        {}

    rquerypivot(std::string path, const std::string& as,
           const std::string& data_type, const std::string& path_type,
           bool verbose)
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
          jsonpointer_(path_type_ == path_type::JSONpointer ? path : "/"),
          verbose_(verbose)
        {}

    // as_r

    sexp as_r(const std::vector<std::string>& data)
        {
            return do_strings(data, &rquerypivot::identity_transform);
        }

    sexp as_r(const sexp& con, double n_records)
        {
            return
                do_connection(con, n_records, &rquerypivot::identity_transform);
        }

    // query

    sexp query(const std::vector<std::string>& data)
        {
            // json_data_type has data.size() == 1
            return do_strings(data, &rquerypivot::query_transform);
        }

    sexp query(const sexp& con, double n_records)
        {
            return do_connection(con, n_records, &rquerypivot::query_transform);
        }

    // pivot

    sexp pivot(const std::vector<std::string>& data)
        {
            // collect queries across all data
            return do_strings(data, &rquerypivot::pivot_transform);
        }

    sexp pivot(const sexp& con, double n_records)
        {
            return do_connection(con, n_records, &rquerypivot::pivot_transform);
        }

    // flatten

    sexp flatten(const std::vector<std::string>& data)
        {
            return do_strings(data, &rquerypivot::flatten_transform);
        }

    sexp flatten(const sexp& con, double n_records)
        {
            return
                do_connection(con, n_records, &rquerypivot::flatten_transform);
        }

    // as

    sexp as() const
        {
            progressbar progress("coercing {cli::pb_current} records");
            const writable::list result(result_.size());
            auto fun = [&](Json j) {
                if (verbose_) {
                    progress.tick();
                }
                return j_as(j, as_);
            };
            std::transform(result_.begin(), result_.end(), result.begin(), fun);

            return as_ == as::string ?
                package("base")["unlist"](result) : result;
        }
};

#endif
