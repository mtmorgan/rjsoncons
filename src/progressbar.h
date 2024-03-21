#ifndef RJSONCONS_PROGRESSBAR_H
#define RJSONCONS_PROGRESSBAR_H

#include <string>
#include <cli/progress.h>

#include <cpp11/sexp.hpp>

using namespace cpp11;

class progressbar {
    sexp bar_;
    int n_;
  public:
    progressbar(const std::string& format)
        : n_(0)
        {
            bar_ = cli_progress_bar(NA_REAL, nullptr);
            cli_progress_set_format(bar_, format.c_str());
        }

    ~progressbar()
        {
            cli_progress_done(bar_);
        }

    void tick()
    {
        n_ += 1;
        if (CLI_SHOULD_TICK) {
            cli_progress_set(bar_, n_);
        }
    }
};

#endif
