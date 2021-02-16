// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"

// test.cpp
std::string cpp_version();
extern "C" SEXP _rjsoncons_cpp_version() {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_version());
  END_CPP11
}
// test.cpp
std::string cpp_jsonpath(std::string data, std::string path);
extern "C" SEXP _rjsoncons_cpp_jsonpath(SEXP data, SEXP path) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_jsonpath(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(path)));
  END_CPP11
}
// test.cpp
std::string cpp_jmespath(std::string data, std::string path);
extern "C" SEXP _rjsoncons_cpp_jmespath(SEXP data, SEXP path) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_jmespath(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(path)));
  END_CPP11
}

extern "C" {
/* .Call calls */
extern SEXP _rjsoncons_cpp_jmespath(SEXP, SEXP);
extern SEXP _rjsoncons_cpp_jsonpath(SEXP, SEXP);
extern SEXP _rjsoncons_cpp_version();

static const R_CallMethodDef CallEntries[] = {
    {"_rjsoncons_cpp_jmespath", (DL_FUNC) &_rjsoncons_cpp_jmespath, 2},
    {"_rjsoncons_cpp_jsonpath", (DL_FUNC) &_rjsoncons_cpp_jsonpath, 2},
    {"_rjsoncons_cpp_version",  (DL_FUNC) &_rjsoncons_cpp_version,  0},
    {NULL, NULL, 0}
};
}

extern "C" void R_init_rjsoncons(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
