// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// rjsoncons.cpp
std::string cpp_version();
extern "C" SEXP _rjsoncons_cpp_version() {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_version());
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_jsonpath(std::string data, std::string path, std::string jtype, std::string as);
extern "C" SEXP _rjsoncons_cpp_jsonpath(SEXP data, SEXP path, SEXP jtype, SEXP as) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_jsonpath(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(path), cpp11::as_cpp<cpp11::decay_t<std::string>>(jtype), cpp11::as_cpp<cpp11::decay_t<std::string>>(as)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_jmespath(std::string data, std::string path, std::string jtype, std::string as);
extern "C" SEXP _rjsoncons_cpp_jmespath(SEXP data, SEXP path, SEXP jtype, SEXP as) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_jmespath(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(path), cpp11::as_cpp<cpp11::decay_t<std::string>>(jtype), cpp11::as_cpp<cpp11::decay_t<std::string>>(as)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_jsonpivot(std::string data, std::string jtype, std::string as);
extern "C" SEXP _rjsoncons_cpp_jsonpivot(SEXP data, SEXP jtype, SEXP as) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_jsonpivot(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(jtype), cpp11::as_cpp<cpp11::decay_t<std::string>>(as)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_as_r(std::string data, std::string jtype);
extern "C" SEXP _rjsoncons_cpp_as_r(SEXP data, SEXP jtype) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_as_r(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(jtype)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_rjsoncons_cpp_as_r",      (DL_FUNC) &_rjsoncons_cpp_as_r,      2},
    {"_rjsoncons_cpp_jmespath",  (DL_FUNC) &_rjsoncons_cpp_jmespath,  4},
    {"_rjsoncons_cpp_jsonpath",  (DL_FUNC) &_rjsoncons_cpp_jsonpath,  4},
    {"_rjsoncons_cpp_jsonpivot", (DL_FUNC) &_rjsoncons_cpp_jsonpivot, 3},
    {"_rjsoncons_cpp_version",   (DL_FUNC) &_rjsoncons_cpp_version,   0},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_rjsoncons(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
