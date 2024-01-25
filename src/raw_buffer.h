#ifndef RJSONCONS_RAW_BUFFER_H
#define RJSONCONS_RAW_BUFFER_H

#include <cstring>
#include <cpp11.hpp>

namespace rjsoncons {

    // Parse an R 'raw' vector into a std::vector<std::string> based
    // on newline delimiters '\n'. The raw vector may contain partial
    // records, so remember the 'remainder' to prefix to the next
    // instance.
    class raw_buffer {
        int n_records_;
        std::vector<uint8_t> raw_;
        std::vector<uint8_t>::iterator buf;

    public:
        raw_buffer(const raws prefix, const raws bin, int n_records)
            : n_records_(n_records)
            {
                raw_.reserve(prefix.size() + bin.size());
                // copy prefix + bin to raw_
                std::copy(prefix.begin(), prefix.end(), std::back_inserter(raw_));
                std::copy(bin.begin(), bin.end(), std::back_inserter(raw_));
            }

        std::vector<std::string> to_strings()
            {
                std::vector<std::string> result;
                buf = raw_.begin();
                do {
                    auto eol = std::find(buf, raw_.end(), (uint8_t) '\n');
                    if (eol == raw_.end()) // not found
                        break;
                    result.push_back(std::string(buf, eol));
                    buf = eol + 1;
                    n_records_ -= 1;
                } while ((n_records_ > 0) && (buf != raw_.end()));

                return result;
            }

        cpp11::raws remainder()
            {
                cpp11::writable::raws raw(raw_.end() - buf);
                std::copy(buf, raw_.end(), raw.begin());
                return raw;
            }
    };
}

#endif
