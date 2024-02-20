#ifndef RJSONCONS_PROGRESSBAR_H
#define RJSONCONS_PROGRESSBAR_H

#include <string>
#include <cpp11.hpp>
#include <cli/progress.h>

class progressbar {
    sexp bar;
    int n;
  public:
    progressbar(std::string format)
        : n(0)
        {
            bar = cli_progress_bar(NA_REAL, NULL);
            cli_progress_set_format(bar, format.c_str());
        }

    ~progressbar()
        {
            cli_progress_done(bar);
        }

    void tick()
    {
        n += 1;
        if (CLI_SHOULD_TICK)
            cli_progress_set(bar, n);
    }
};

#endif
