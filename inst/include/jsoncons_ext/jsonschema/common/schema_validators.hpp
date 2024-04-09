// Copyright 2013-2024 Daniel Parker
// Distributed under the Boost license, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

// See https://github.com/danielaparker/jsoncons for latest version

#ifndef JSONCONS_JSONSCHEMA_COMMON_SCHEMA_VALIDATORS_HPP
#define JSONCONS_JSONSCHEMA_COMMON_SCHEMA_VALIDATORS_HPP

#include <jsoncons/config/jsoncons_config.hpp>
#include <jsoncons/uri.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonschema/common/evaluation_context.hpp>
#include <jsoncons_ext/jsonschema/common/keyword_validators.hpp>
#include <jsoncons_ext/jsonschema/jsonschema_error.hpp>
#include <unordered_set>

namespace jsoncons {
namespace jsonschema {

    template <class Json>
    class document_schema_validator : public schema_validator<Json>
    {
        using keyword_validator_type = std::unique_ptr<keyword_validator<Json>>;
        using schema_validator_type = std::unique_ptr<schema_validator<Json>>;

        schema_validator_type schema_val_;
        std::vector<schema_validator_type> schemas_;
    public:
        document_schema_validator(schema_validator_type&& schema_val, std::vector<schema_validator_type>&& schemas)
            : schema_val_(std::move(schema_val)), schemas_(std::move(schemas))
        {
            if (schema_val_ == nullptr)
                JSONCONS_THROW(schema_error("There is no schema to validate an instance against"));
        }

        document_schema_validator(const document_schema_validator&) = delete;
        document_schema_validator(document_schema_validator&&) = default;
        document_schema_validator& operator=(const document_schema_validator&) = delete;
        document_schema_validator& operator=(document_schema_validator&&) = default;      

        jsoncons::optional<Json> get_default_value() const final
        {
            return schema_val_->get_default_value();
        }

        const uri& schema_location() const final
        {
            return schema_val_->schema_location();
        }

        bool recursive_anchor() const final
        {
            return schema_val_->recursive_anchor();
        }

        const jsoncons::optional<jsoncons::uri>& id() const final
        {
            return schema_val_->id();
        }

        const jsoncons::optional<jsoncons::uri>& dynamic_anchor() const final
        {
            return schema_val_->dynamic_anchor();
        }

        const schema_validator<Json>* get_schema_for_dynamic_anchor(const std::string& anchor) const final
        {
            return schema_val_->get_schema_for_dynamic_anchor(anchor);
        }

        bool always_fails() const final
        {
            return schema_val_->always_fails();
        }

        bool always_succeeds() const final
        {
            return schema_val_->always_succeeds();
        }
        
    private:
        void do_validate(const evaluation_context<Json>& context, 
            const Json& instance, 
            const jsonpointer::json_pointer& instance_location,
            evaluation_results& results,
            error_reporter& reporter, 
            Json& patch) const 
        {
            JSONCONS_ASSERT(schema_val_ != nullptr);
            schema_val_->validate(context, instance, instance_location, results, reporter, patch);
        }
    };

    template <class Json>
    class boolean_schema_validator : public schema_validator<Json>
    {
    public:
        using schema_validator_type = typename std::unique_ptr<schema_validator<Json>>;
        using keyword_validator_type = typename std::unique_ptr<keyword_validator<Json>>;

        uri schema_location_;
        bool value_;

        jsoncons::optional<jsoncons::uri> id_;

        jsoncons::optional<jsoncons::uri> dynamic_anchor_;

    public:
        boolean_schema_validator(const uri& schema_location, bool value)
            : schema_location_(schema_location), value_(value)
        {
        }

        jsoncons::optional<Json> get_default_value() const final
        {
            return jsoncons::optional<Json>{};
        }

        const uri& schema_location() const final
        {
            return schema_location_;
        }

        bool recursive_anchor() const final
        {
            return false;
        }

        const jsoncons::optional<jsoncons::uri>& id() const final
        {
            return id_;
        }

        const jsoncons::optional<jsoncons::uri>& dynamic_anchor() const final
        {
            return dynamic_anchor_;
        }

        const schema_validator<Json>* get_schema_for_dynamic_anchor(const std::string& /*anchor*/) const final
        {
            return nullptr;
        }

        bool always_fails() const final
        {
            return !value_;
        }

        bool always_succeeds() const final
        {
            return value_;
        }

    private:

        void do_validate(const evaluation_context<Json>& context, const Json&, 
            const jsonpointer::json_pointer& instance_location,
            evaluation_results& /*results*/, 
            error_reporter& reporter, 
            Json& /*patch*/) const final
        {
            if (!value_)
            {
                reporter.error(validation_message("false", 
                    context.eval_path(),
                    this->schema_location(), 
                    instance_location, 
                    "False schema always fails"));
            }
        }
    };
 
    template <class Json>
    class object_schema_validator : public schema_validator<Json>
    {
    public:
        using schema_validator_type = typename std::unique_ptr<schema_validator<Json>>;
        using keyword_validator_type = typename std::unique_ptr<keyword_validator<Json>>;
        using anchor_schema_map_type = std::unordered_map<std::string,std::unique_ptr<ref_validator<Json>>>;

        uri schema_location_;
        jsoncons::optional<jsoncons::uri> id_;
        std::vector<keyword_validator_type> validators_; 
        std::unique_ptr<unevaluated_properties_validator<Json>> unevaluated_properties_val_;
        std::unique_ptr<unevaluated_items_validator<Json>> unevaluated_items_val_;
        std::map<std::string,schema_validator_type> defs_;
        Json default_value_;
        bool recursive_anchor_;
        jsoncons::optional<jsoncons::uri> dynamic_anchor_;
        anchor_schema_map_type anchor_dict_;

    public:
        object_schema_validator(const uri& schema_location, 
            const jsoncons::optional<jsoncons::uri>& id,
            std::vector<keyword_validator_type>&& validators, 
            std::map<std::string,schema_validator_type>&& defs,
            Json&& default_value)
            : schema_location_(schema_location),
              id_(id),
              validators_(std::move(validators)),
              defs_(std::move(defs)),
              default_value_(std::move(default_value)),
              recursive_anchor_(false)
        {
        }
        object_schema_validator(const uri& schema_location, 
            const jsoncons::optional<jsoncons::uri>& id,
            std::vector<keyword_validator_type>&& validators,
            std::unique_ptr<unevaluated_properties_validator<Json>>&& unevaluated_properties_val, 
            std::unique_ptr<unevaluated_items_validator<Json>>&& unevaluated_items_val, 
            std::map<std::string,schema_validator_type>&& defs,
            Json&& default_value, bool recursive_anchor)
            : schema_location_(schema_location),
              id_(id),
              validators_(std::move(validators)),
              unevaluated_properties_val_(std::move(unevaluated_properties_val)),
              unevaluated_items_val_(std::move(unevaluated_items_val)),
              defs_(std::move(defs)),
              default_value_(std::move(default_value)),
              recursive_anchor_(recursive_anchor)
        {
        }
        object_schema_validator(const uri& schema_location, 
            const jsoncons::optional<jsoncons::uri>& id,
            std::vector<keyword_validator_type>&& validators, 
            std::unique_ptr<unevaluated_properties_validator<Json>>&& unevaluated_properties_val, 
            std::unique_ptr<unevaluated_items_validator<Json>>&& unevaluated_items_val, 
            std::map<std::string,schema_validator_type>&& defs,
            Json&& default_value,
            jsoncons::optional<jsoncons::uri>&& dynamic_anchor,
            anchor_schema_map_type&& anchor_dict)
            : schema_location_(schema_location),
              id_(std::move(id)),
              validators_(std::move(validators)),
              unevaluated_properties_val_(std::move(unevaluated_properties_val)),
              unevaluated_items_val_(std::move(unevaluated_items_val)),
              defs_(std::move(defs)),
              default_value_(std::move(default_value)),
              recursive_anchor_(false),
              dynamic_anchor_(std::move(dynamic_anchor)),
              anchor_dict_(std::move(anchor_dict))
        {
        }

        jsoncons::optional<Json> get_default_value() const override
        {
            return default_value_;
        }

        const uri& schema_location() const override
        {
            return schema_location_;
        }

        bool recursive_anchor() const final
        {
            return recursive_anchor_;
        }

        const jsoncons::optional<jsoncons::uri>& id() const final
        {
            return id_;
        }

        const schema_validator<Json>* get_schema_for_dynamic_anchor(const std::string& anchor) const final
        {
            auto it = anchor_dict_.find(anchor);
            return (it == anchor_dict_.end()) ? nullptr : it->second->referred_schema();
        }

        const jsoncons::optional<jsoncons::uri>& dynamic_anchor() const final
        {
            return dynamic_anchor_;
        }

        bool always_fails() const final
        {
            return false;
        }

        bool always_succeeds() const final
        {
            return false;
        }

    private:

        void do_validate(const evaluation_context<Json>& context, const Json& instance, 
            const jsonpointer::json_pointer& instance_location,
            evaluation_results& results, 
            error_reporter& reporter, 
            Json& patch) const final
        {
            //std::cout << "object_schema_validator begin[" << context.eval_path().string() << "," << this->schema_location().string() << "]";
            //std::cout << "results:\n";
            //for (const auto& s : results)
            //{
            //    std::cout << "    " << s << "\n";
            //}
            //std::cout << "\n";
          
            
            evaluation_results local_results;

            evaluation_flags flags = context.eval_flags();
            if (unevaluated_properties_val_)
            {
                flags |= evaluation_flags::require_evaluated_properties;
            }
            if (unevaluated_items_val_)
            {
                flags |= evaluation_flags::require_evaluated_items;
            }

            evaluation_context<Json> this_context{context, this, flags};
            
            //std::cout << "validators:\n";
            for (auto& val : validators_)
            {               
                //std::cout << "    " << val->keyword_name() << "\n";
                val->validate(this_context, instance, instance_location, local_results, reporter, patch);
                if (reporter.error_count() > 0 && reporter.fail_early())
                {
                    return;
                }
            }
            
            if (unevaluated_properties_val_)
            {
                unevaluated_properties_val_->validate(this_context, instance, instance_location, local_results, reporter, patch);
                if (reporter.error_count() > 0 && reporter.fail_early())
                {
                    return;
                }
            }

            if (unevaluated_items_val_)
            {
                unevaluated_items_val_->validate(this_context, instance, instance_location, local_results, reporter, patch);
                if (reporter.error_count() > 0 && reporter.fail_early())
                {
                    return;
                }
            }

            if ((context.eval_flags() & evaluation_flags::require_evaluated_properties)
                 == evaluation_flags::require_evaluated_properties)
            {
                results.merge(std::move(local_results.evaluated_properties));
            }
            if ((context.eval_flags() & evaluation_flags::require_evaluated_items)
                 == evaluation_flags::require_evaluated_items)
            {
                results.merge(std::move(local_results.evaluated_items));
            }
            
            //std::cout << "object_schema_validator end[" << context.eval_path().string() << "," << this->schema_location().string() << "]";
            //std::cout << "results:\n";
            //for (const auto& s : results)
            //{
            //    std::cout << "    " << s << "\n";
            //}
            //std::cout << "\n";
        }
    };

} // namespace jsonschema
} // namespace jsoncons

#endif // JSONCONS_JSONSCHEMA_KEYWORD_VALIDATOR_HPP
