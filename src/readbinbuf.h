#ifndef READBINBUF_H
#define READBINBUF_H

#include <streambuf>
#include <cpp11.hpp>

// wrap an R connection as a std::streambuf filled with readBin()
//
// https://stackoverflow.com/a/14086442/547331
// https://github.com/tidyverse/readr/blob/main/src/connection.cpp
class readbinbuf : public std::streambuf {
    // inline is a C++17 extension
    // inline static auto read_bin = cpp11::package("base")["readBin"];
    static cpp11::function read_bin; // defined in rjsoncons.cpp
    const cpp11::sexp& con_;
    char *buf_;
    const int n_bytes_ = 1 << 22; // 4 Mb buffer

  public:

    readbinbuf(const cpp11::sexp& con) : con_(con) {
        buf_ = new char[n_bytes_];
    }

    ~readbinbuf() { delete buf_; }

    int underflow() {
        if (gptr() == egptr()) {
            SEXP chunk = read_bin(con_, "raw", n_bytes_);
            R_xlen_t chunk_len = Rf_xlength(chunk);
            // copy data to avoid worrying about PROTECTion
            std::copy(RAW(chunk), RAW(chunk) + chunk_len, buf_);
            setg(buf_, buf_, buf_ + chunk_len);
        }
        return gptr() == egptr() ?
            std::char_traits<char>::eof() :
            std::char_traits<char>::to_int_type(*gptr());
    }
};

#endif
