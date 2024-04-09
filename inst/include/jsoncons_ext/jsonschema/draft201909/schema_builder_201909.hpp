// Copyright 2013-2024 Daniel Parker
// Distributed under the Boost license, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

// See https://github.com/danielaparker/jsoncons for latest version

#ifndef JSONCONS_JSONSCHEMA_DRAFT201909_SCHEMA_BUILDER_201909_HPP
#define JSONCONS_JSONSCHEMA_DRAFT201909_SCHEMA_BUILDER_201909_HPP

#include <jsoncons/uri.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonpointer/jsonpointer.hpp>
#include <jsoncons_ext/jsonschema/common/compilation_context.hpp>
#include <jsoncons_ext/jsonschema/json_schema.hpp>
#include <jsoncons_ext/jsonschema/common/schema_validators.hpp>
#include <jsoncons_ext/jsonschema/common/schema_builder.hpp>
#include <jsoncons_ext/jsonschema/draft201909/schema_draft201909.hpp>
#include <cassert>
#include <set>
#include <sstream>
#include <iostream>
#include <cassert>
#if defined(JSONCONS_HAS_STD_REGEX)
#include <regex>
#endif

namespace jsoncons {
namespace jsonschema {
namespace draft201909 {

    template <class Json>
    class schema_builder_201909 : public schema_builder<Json> 
    {
    public:
        using schema_store_type = typename schema_builder<Json>::schema_store_type;
        using schema_builder_factory_type = typename schema_builder<Json>::schema_builder_factory_type;
        using keyword_validator_type = typename std::unique_ptr<keyword_validator<Json>>;
        using schema_validator_type = typename std::unique_ptr<schema_validator<Json>>;
        using recursive_ref_validator_type = recursive_ref_validator<Json>;
        using anchor_uri_map_type = std::unordered_map<std::string,uri_wrapper>;

        using keyword_factory_type = std::function<keyword_validator_type(const compilation_context& context, 
            const Json& sch, const Json& parent, anchor_uri_map_type&)>;

        std::unordered_map<std::string,keyword_factory_type> validation_factory_map_;

        static const std::string& core_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/core";
            return id;
        }
        static const std::string& applicator_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/applicator";
            return id;
        }
        static const std::string& unevaluated_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/unevaluated";
            return id;
        }
        static const std::string& validation_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/validation";
            return id;
        }
        static const std::string& meta_data_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/meta-data";
            return id;
        }
        static const std::string& format_annotation_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/format-annotation";
            return id;
        }
        static const std::string& content_id()
        {
            static std::string id = "https://json-schema.org/draft/2019-09/vocab/content";
            return id;
        }

        bool include_applicator_;
        bool include_unevaluated_;
        bool include_validation_;
        bool include_format_;

    public:
        schema_builder_201909(const schema_builder_factory_type& builder_factory, 
            evaluation_options options, schema_store_type* schema_store_ptr,
            const std::vector<schema_resolver<Json>>& resolvers,
            const std::unordered_map<std::string,bool>& vocabulary) noexcept
            : schema_builder<Json>(schema_version::draft201909(), 
                builder_factory, options, schema_store_ptr, resolvers, vocabulary),
                include_applicator_(true), include_unevaluated_(true), include_validation_(true), include_format_(true)
        {
            if (!vocabulary.empty())
            {
                auto it = vocabulary.find(applicator_id());
                if (it == vocabulary.end() || !(it->second))
                {
                    include_applicator_ = false;
                }
                it = vocabulary.find(unevaluated_id());
                if (it == vocabulary.end() || !(it->second))
                {
                    include_unevaluated_ = false;
                }
                it = vocabulary.find(validation_id());
                if (it == vocabulary.end() || !(it->second))
                {
                    include_validation_ = false;
                }
                it = vocabulary.find(format_annotation_id());
                if (it == vocabulary.end() || !(it->second))
                {
                    include_format_ = false;
                }
            }
            init();
        }

        schema_builder_201909(const schema_builder_201909&) = delete;
        schema_builder_201909& operator=(const schema_builder_201909&) = delete;
        schema_builder_201909(schema_builder_201909&&) = default;
        schema_builder_201909& operator=(schema_builder_201909&&) = default;

        void init()
        {
            validation_factory_map_.emplace("type", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_type_validator(context, sch);});
/*
            validation_factory_map_.emplace("contentEncoding", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_content_encoding_validator(context, sch);});
            validation_factory_map_.emplace("contentMediaType", 
                [&](const compilation_context& context, const Json& sch, const Json& parent, anchor_uri_map_type&){return this->make_content_media_type_validator(context, sch, parent);});
*/
#if defined(JSONCONS_HAS_STD_REGEX)
            validation_factory_map_.emplace("pattern", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_pattern_validator(context, sch);});
#endif
            validation_factory_map_.emplace("maxItems", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_max_items_validator(context, sch);});
            validation_factory_map_.emplace("minItems", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_min_items_validator(context, sch);});
            validation_factory_map_.emplace("maxProperties", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_max_properties_validator(context, sch);});
            validation_factory_map_.emplace("minProperties", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_min_properties_validator(context, sch);});
            validation_factory_map_.emplace("contains", 
                [&](const compilation_context& context, const Json& sch, const Json& parent, anchor_uri_map_type& anchor_dict)
                        {return this->make_contains_validator(context, sch, parent, anchor_dict);});
            validation_factory_map_.emplace("uniqueItems", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_unique_items_validator(context, sch);});
            validation_factory_map_.emplace("maxLength", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_max_length_validator(context, sch);});
            validation_factory_map_.emplace("minLength", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_min_length_validator(context, sch);});
            validation_factory_map_.emplace("not", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type& anchor_dict){return this->make_not_validator(context, sch, anchor_dict);});
            validation_factory_map_.emplace("maximum", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_maximum_validator(context, sch);});
            validation_factory_map_.emplace("exclusiveMaximum", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_exclusive_maximum_validator(context, sch);});
            validation_factory_map_.emplace("minimum", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_minimum_validator(context, sch);});
            validation_factory_map_.emplace("exclusiveMinimum", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_exclusive_minimum_validator(context, sch);});
            validation_factory_map_.emplace("multipleOf", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_multiple_of_validator(context, sch);});
            validation_factory_map_.emplace("const", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_const_validator(context, sch);});
            validation_factory_map_.emplace("enum", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_enum_validator(context, sch);});
            validation_factory_map_.emplace("allOf", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type& anchor_dict){return this->make_all_of_validator(context, sch, anchor_dict);});
            validation_factory_map_.emplace("anyOf", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type& anchor_dict){return this->make_any_of_validator(context, sch, anchor_dict);});
            validation_factory_map_.emplace("oneOf", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type& anchor_dict){return this->make_one_of_validator(context, sch, anchor_dict);});
            if (this->options().compatibility_mode())
            {           
                validation_factory_map_.emplace("dependencies", 
                    [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type& anchor_dict){return this->make_dependencies_validator(context, sch, anchor_dict);});
            }
            validation_factory_map_.emplace("required", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_required_validator(context, sch);});
            validation_factory_map_.emplace("dependentRequired", 
                [&](const compilation_context& context, const Json& sch, const Json&, anchor_uri_map_type&){return this->make_dependent_required_validator(context, sch);});
        }

        schema_validator_type make_schema_validator(const compilation_context& context, 
            const Json& sch, jsoncons::span<const std::string> keys, anchor_uri_map_type& anchor_dict) override
        {
            auto new_context = make_compilation_context(context, sch, keys);
            //std::cout << "make_schema_validator " << context.get_base_uri().string() << ", " << new_context.get_base_uri().string() << "\n\n";

            schema_validator_type schema_validator_ptr;

            switch (sch.type())
            {
                case json_type::bool_value:
                {
                    schema_validator_ptr = this->make_boolean_schema(new_context, sch);
                    schema_validator<Json>* p = schema_validator_ptr.get();
                    for (const auto& uri : new_context.uris()) 
                    { 
                        this->insert_schema(uri, p);
                    }          
                    break;
                }
                case json_type::object_value:
                {
                    std::set<std::string> known_keywords;

                    schema_validator_ptr = make_object_schema_validator(new_context, sch, anchor_dict);
                    schema_validator<Json>* p = schema_validator_ptr.get();
                    for (const auto& uri : new_context.uris()) 
                    { 
                        this->insert_schema(uri, p);
                        /*for (const auto& item : sch.object_range())
                        {
                            if (known_keywords.find(item.key()) == known_keywords.end())
                            {
                                this->insert_unknown_keyword(uri, item.key(), item.value()); // save unknown keywords for later reference
                            }
                        }*/
                    }          
                    break;
                }
                default:
                    JSONCONS_THROW(schema_error("invalid JSON-type for a schema for " + new_context.get_base_uri().string() + ", expected: boolean or object"));
                    break;
            }
            
            return schema_validator_ptr;
        }

        schema_validator_type make_object_schema_validator( 
            const compilation_context& context, const Json& sch, anchor_uri_map_type& anchor_dict)
        {
            jsoncons::optional<jsoncons::uri> id = context.id();
            Json default_value{ jsoncons::null_type()};
            std::vector<keyword_validator_type> validators;
            std::unique_ptr<unevaluated_properties_validator<Json>> unevaluated_properties_val;
            std::unique_ptr<unevaluated_items_validator<Json>> unevaluated_items_val;
            std::set<std::string> known_keywords;
            bool recursive_anchor = false;
            std::map<std::string,schema_validator_type> defs;

            if (this->options().compatibility_mode())
            {
                auto it = sch.find("definitions");
                if (it != sch.object_range().end()) 
                {
                    for (const auto& def : it->value().object_range())
                    {
                        std::string sub_keys[] = { "definitions", def.key() };
                        defs.emplace(def.key(), make_schema_validator(context, def.value(), sub_keys, anchor_dict));
                    }
                    known_keywords.insert("definitions");
                }
            }
            auto it = sch.find("$defs");
            if (it != sch.object_range().end()) 
            {
                for (const auto& def : it->value().object_range())
                {
                    std::string sub_keys[] = { "$defs", def.key() };
                    defs.emplace(def.key(), make_schema_validator(context, def.value(), sub_keys, anchor_dict));
                }
                known_keywords.insert("$defs");
            }

            it = sch.find("$recursiveAnchor"); 
            if (it != sch.object_range().end()) 
            {
                recursive_anchor = it->value().template as<bool>();
            }

            it = sch.find("default");
            if (it != sch.object_range().end()) 
            {
                default_value = it->value();
                known_keywords.insert("default");
            }

            it = sch.find("$ref");
            if (it != sch.object_range().end()) // this schema has a reference
            {
                uri_wrapper relative(it->value().template as<std::string>()); 
                auto resolved = relative.resolve(uri_wrapper{ context.get_base_uri() });
                validators.push_back(this->get_or_create_reference(resolved));
            }

            it = sch.find("$recursiveRef");
            if (it != sch.object_range().end()) // this schema has a reference
            {
                uri_wrapper relative(it->value().template as<std::string>());
                auto ref = relative.resolve(uri_wrapper
                { context.get_base_uri()});
                auto orig = jsoncons::make_unique<recursive_ref_validator_type>(ref.uri().base()); 
                this->unresolved_refs_.emplace_back(ref.uri(), orig.get());
                validators.push_back(std::move(orig));
            }
            
            if (include_applicator_)
            {               
                it = sch.find("propertyNames");
                if (it != sch.object_range().end()) 
                {
                    validators.emplace_back(this->make_property_names_validator(context, it->value(), anchor_dict));
                }

                it = sch.find("dependentSchemas");
                if (it != sch.object_range().end()) 
                {
                    validators.emplace_back(this->make_dependent_schemas_validator(context, it->value(), anchor_dict));
                }
                
                schema_validator_type if_validator;
                schema_validator_type then_validator;
                schema_validator_type else_validator;
    
                it = sch.find("if");
                if (it != sch.object_range().end()) 
                {
                    std::string sub_keys[] = { "if" };
                    if_validator = make_schema_validator(context, it->value(), sub_keys, anchor_dict);
                }
    
                it = sch.find("then");
                if (it != sch.object_range().end()) 
                {
                    std::string sub_keys[] = { "then" };
                    then_validator = make_schema_validator(context, it->value(), sub_keys, anchor_dict);
                }
    
                it = sch.find("else");
                if (it != sch.object_range().end()) 
                {
                    std::string sub_keys[] = { "else" };
                    else_validator = make_schema_validator(context, it->value(), sub_keys, anchor_dict);
                }
                if (if_validator || then_validator || else_validator)
                {
                    validators.emplace_back(jsoncons::make_unique<conditional_validator<Json>>(
                        context.get_base_uri().string(),
                        std::move(if_validator), std::move(then_validator), std::move(else_validator)));
                }
                
                // Object validators
    
                std::unique_ptr<properties_validator<Json>> properties;
                it = sch.find("properties");
                if (it != sch.object_range().end()) 
                {
                    properties = this->make_properties_validator(context, it->value(), anchor_dict);
                }
                std::unique_ptr<pattern_properties_validator<Json>> pattern_properties;
    
        #if defined(JSONCONS_HAS_STD_REGEX)
                it = sch.find("patternProperties");
                if (it != sch.object_range().end())
                {
                    pattern_properties = make_pattern_properties_validator(context, it->value(), anchor_dict);
                }
        #endif
    
                it = sch.find("additionalProperties");
                if (it != sch.object_range().end()) 
                {
                    validators.emplace_back(this->make_additional_properties_validator(context, it->value(), 
                        std::move(properties), std::move(pattern_properties), anchor_dict));
                }
                else
                {
                    if (properties)
                    {
                        validators.emplace_back(std::move(properties));
                    }
    #if defined(JSONCONS_HAS_STD_REGEX)
                    if (pattern_properties)
                    {
                        validators.emplace_back(std::move(pattern_properties));
                    }
    #endif
                }
    
                it = sch.find("items");
                if (it != sch.object_range().end()) 
                {
    
                    if (it->value().type() == json_type::array_value) 
                    {
                        validators.emplace_back(this->make_prefix_items_validator_07(context, sch, it->value(), anchor_dict));
                    } 
                    else if (it->value().type() == json_type::object_value ||
                               it->value().type() == json_type::bool_value)
                    {
                        validators.emplace_back(this->make_items_validator("items", context, it->value(), anchor_dict));
                    }
                }
            }
            if (include_validation_)
            {
                for (const auto& key_value : sch.object_range())
                {
                    auto factory_it = validation_factory_map_.find(key_value.key());
                    if (factory_it != validation_factory_map_.end())
                    {
                        auto validator = factory_it->second(context, key_value.value(), sch, anchor_dict);
                        if (validator)
                        {   
                            validators.emplace_back(std::move(validator));
                        }
                    }
                }
            }

            if (include_format_)
            {
                if (this->options().require_format_validation())
                {
                    validators.emplace_back(this->make_format_validator(context, sch));
                }
            }
            if (include_unevaluated_)
            {
                it = sch.find("unevaluatedProperties");
                if (it != sch.object_range().end()) 
                {
                    unevaluated_properties_val = this->make_unevaluated_properties_validator(context, it->value(), anchor_dict);
                }
                it = sch.find("unevaluatedItems");
                if (it != sch.object_range().end()) 
                {
                    unevaluated_items_val = this->make_unevaluated_items_validator(context, it->value(), anchor_dict);
                }
            }
            
            return jsoncons::make_unique<object_schema_validator<Json>>(context.get_base_uri(), std::move(id),
                std::move(validators), std::move(unevaluated_properties_val), std::move(unevaluated_items_val), 
                std::move(defs), std::move(default_value), recursive_anchor);
        }

#if defined(JSONCONS_HAS_STD_REGEX)
                
        std::unique_ptr<pattern_properties_validator<Json>> make_pattern_properties_validator( const compilation_context& context, 
            const Json& sch, anchor_uri_map_type& anchor_dict)
        {
            uri schema_location = context.get_base_uri();
            std::vector<std::pair<std::regex, schema_validator_type>> pattern_properties;
            
            for (const auto& prop : sch.object_range())
            {
                std::string sub_keys[] = {prop.key()};
                pattern_properties.emplace_back(
                    std::make_pair(
                        std::regex(prop.key(), std::regex::ECMAScript),
                        make_schema_validator(context, prop.value(), sub_keys, anchor_dict)));
            }

            return jsoncons::make_unique<pattern_properties_validator<Json>>( std::move(schema_location),
                std::move(pattern_properties));
        }
#endif       

    private:

        compilation_context make_compilation_context(const compilation_context& parent, 
            const Json& sch, jsoncons::span<const std::string> keys) const override
        {
            // Exclude uri's that are not plain name identifiers
            std::vector<uri_wrapper> new_uris;
            for (const auto& uri : parent.uris())
            {
                if (!uri.has_plain_name_fragment())
                {
                    new_uris.push_back(uri);
                }
            }

            // Append the keys for this sub-schema to the uri's
            for (const auto& key : keys)
            {
                for (auto& uri : new_uris)
                {
                    auto new_u = uri.append(key);
                    uri = uri_wrapper(new_u);
                }
            }

            jsoncons::optional<uri> id;
            if (sch.is_object())
            {
                auto it = sch.find("$id"); // If $id is found, this schema can be referenced by the id
                if (it != sch.object_range().end()) 
                {
                    uri_wrapper relative(it->value().template as<std::string>()); 
                    if (relative.has_fragment())
                    {
                        JSONCONS_THROW(schema_error("Draft 2019-09 does not allow $id with fragment"));
                    }
                    uri_wrapper new_uri = relative.resolve(uri_wrapper{ parent.get_base_uri() });
                    id = new_uri.uri();
                    //std::cout << "$id: " << id << ", " << new_uri.string() << "\n";
                    // Add it to the list if it is not already there
                    if (std::find(new_uris.begin(), new_uris.end(), new_uri) == new_uris.end())
                    {
                        new_uris.emplace_back(new_uri); 
                    }
                }
                it = sch.find("$anchor"); 
                if (it != sch.object_range().end()) 
                {
                    auto anchor = it->value().template as<std::string>();
                    if (!this->validate_anchor(anchor))
                    {
                        JSONCONS_THROW(schema_error("Invalid $anchor " + anchor));
                    }
                    auto uri = !new_uris.empty() ? new_uris.back().uri() : jsoncons::uri{"#"};
                    jsoncons::uri new_uri(uri, uri_fragment_part, anchor);
                    uri_wrapper identifier{ new_uri };
                    if (std::find(new_uris.begin(), new_uris.end(), identifier) == new_uris.end())
                    {
                        new_uris.emplace_back(std::move(identifier)); 
                    }
                }
            }

/*
            std::cout << "Absolute URI: " << parent.get_base_uri().string() << "\n";
            for (const auto& uri : new_uris)
            {
                std::cout << "    " << uri.string() << "\n";
            }
*/
            return compilation_context(new_uris, id);
        }

    };

} // namespace draft201909
} // namespace jsonschema
} // namespace jsoncons

#endif // JSONCONS_JSONSCHEMA_DRAFT7_KEYWORD_FACTORY_HPP
