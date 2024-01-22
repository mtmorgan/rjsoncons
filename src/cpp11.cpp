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
sexp cpp_as_r(std::string data, const std::string object_names);
extern "C" SEXP _rjsoncons_cpp_as_r(SEXP data, SEXP object_names) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_as_r(cpp11::as_cpp<cpp11::decay_t<std::string>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_r_json_init(const std::string object_names, const std::string path, const std::string as, const std::string data_type, const std::string path_type);
extern "C" SEXP _rjsoncons_cpp_r_json_init(SEXP object_names, SEXP path, SEXP as, SEXP data_type, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_r_json_init(cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string>>(path_type)));
  END_CPP11
}
// rjsoncons.cpp
void cpp_r_json_query(sexp ext, const std::vector<std::string> data, const std::string object_names);
extern "C" SEXP _rjsoncons_cpp_r_json_query(SEXP ext, SEXP data, SEXP object_names) {
  BEGIN_CPP11
    cpp_r_json_query(cpp11::as_cpp<cpp11::decay_t<sexp>>(ext), cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names));
    return R_NilValue;
  END_CPP11
}
// rjsoncons.cpp
void cpp_r_json_pivot(sexp ext, const std::vector<std::string> data, const std::string object_names);
extern "C" SEXP _rjsoncons_cpp_r_json_pivot(SEXP ext, SEXP data, SEXP object_names) {
  BEGIN_CPP11
    cpp_r_json_pivot(cpp11::as_cpp<cpp11::decay_t<sexp>>(ext), cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names));
    return R_NilValue;
  END_CPP11
}
// rjsoncons.cpp
cpp11::sexp cpp_r_json_finish(sexp ext, const std::string object_names);
extern "C" SEXP _rjsoncons_cpp_r_json_finish(SEXP ext, SEXP object_names) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_r_json_finish(cpp11::as_cpp<cpp11::decay_t<sexp>>(ext), cpp11::as_cpp<cpp11::decay_t<const std::string>>(object_names)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_rjsoncons_cpp_as_r",          (DL_FUNC) &_rjsoncons_cpp_as_r,          2},
    {"_rjsoncons_cpp_r_json_finish", (DL_FUNC) &_rjsoncons_cpp_r_json_finish, 2},
    {"_rjsoncons_cpp_r_json_init",   (DL_FUNC) &_rjsoncons_cpp_r_json_init,   5},
    {"_rjsoncons_cpp_r_json_pivot",  (DL_FUNC) &_rjsoncons_cpp_r_json_pivot,  3},
    {"_rjsoncons_cpp_r_json_query",  (DL_FUNC) &_rjsoncons_cpp_r_json_query,  3},
    {"_rjsoncons_cpp_version",       (DL_FUNC) &_rjsoncons_cpp_version,       0},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_rjsoncons(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
