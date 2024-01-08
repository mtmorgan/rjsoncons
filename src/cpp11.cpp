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
sexp cpp_j_query(const std::string data, const std::string path, const std::string object_names, const std::string as, const std::string path_type);
extern "C" SEXP _rjsoncons_cpp_j_query(SEXP data, SEXP path, SEXP object_names, SEXP as, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_query(cpp11::as_cpp<cpp11::decay_t<const std::string>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path_type)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_j_pivot(const std::string data, const std::string path, const std::string object_names, const std::string as, const std::string path_type);
extern "C" SEXP _rjsoncons_cpp_j_pivot(SEXP data, SEXP path, SEXP object_names, SEXP as, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_pivot(cpp11::as_cpp<cpp11::decay_t<const std::string>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path_type)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_as_r(std::string data, std::string jtype);
extern "C" SEXP _rjsoncons_cpp_as_r(SEXP data, SEXP jtype) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_as_r(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<std::string>>(jtype)));
  END_CPP11
}
// rjsoncons.cpp
cpp11::list cpp_ndjson_query(const std::vector<std::string> data, const std::string path, const std::string object_names, const std::string as, const std::string path_type);
extern "C" SEXP _rjsoncons_cpp_ndjson_query(SEXP data, SEXP path, SEXP object_names, SEXP as, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_ndjson_query(cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path_type)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_rjsoncons_cpp_as_r",         (DL_FUNC) &_rjsoncons_cpp_as_r,         2},
    {"_rjsoncons_cpp_j_pivot",      (DL_FUNC) &_rjsoncons_cpp_j_pivot,      5},
    {"_rjsoncons_cpp_j_query",      (DL_FUNC) &_rjsoncons_cpp_j_query,      5},
    {"_rjsoncons_cpp_ndjson_query", (DL_FUNC) &_rjsoncons_cpp_ndjson_query, 5},
    {"_rjsoncons_cpp_version",      (DL_FUNC) &_rjsoncons_cpp_version,      0},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_rjsoncons(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
