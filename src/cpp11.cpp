// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// patch.cpp
sexp cpp_j_patch_apply(const std::string& data, const std::string& data_type, const std::string& patch, const std::string& as);
extern "C" SEXP _rjsoncons_cpp_j_patch_apply(SEXP data, SEXP data_type, SEXP patch, SEXP as) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_patch_apply(cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(patch), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as)));
  END_CPP11
}
// patch.cpp
sexp cpp_j_patch_from(const std::string& data_x, const std::string& data_type_x, const std::string& data_y, const std::string& data_type_y, const std::string& as);
extern "C" SEXP _rjsoncons_cpp_j_patch_from(SEXP data_x, SEXP data_type_x, SEXP data_y, SEXP data_type_y, SEXP as) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_patch_from(cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_x), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type_x), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_y), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type_y), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as)));
  END_CPP11
}
// rjsoncons.cpp
std::string cpp_version();
extern "C" SEXP _rjsoncons_cpp_version() {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_version());
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_as_r(const std::vector<std::string>& data, const std::string& data_type, const std::string& object_names);
extern "C" SEXP _rjsoncons_cpp_as_r(SEXP data, SEXP data_type, SEXP object_names) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_as_r(cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>&>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_as_r_con(const sexp& con, const std::string& data_type, const std::string& object_names, const double n_records, const bool verbose);
extern "C" SEXP _rjsoncons_cpp_as_r_con(SEXP con, SEXP data_type, SEXP object_names, SEXP n_records, SEXP verbose) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_as_r_con(cpp11::as_cpp<cpp11::decay_t<const sexp&>>(con), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names), cpp11::as_cpp<cpp11::decay_t<const double>>(n_records), cpp11::as_cpp<cpp11::decay_t<const bool>>(verbose)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_j_query(const std::vector<std::string>& data, const std::string& data_type, const std::string& object_names, const std::string& as, const std::string& path, const std::string& path_type);
extern "C" SEXP _rjsoncons_cpp_j_query(SEXP data, SEXP data_type, SEXP object_names, SEXP as, SEXP path, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_query(cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>&>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path_type)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_j_query_con(const sexp& con, const std::string& data_type, const std::string& object_names, const std::string& as, const std::string& path, const std::string& path_type, const double n_records, const bool verbose);
extern "C" SEXP _rjsoncons_cpp_j_query_con(SEXP con, SEXP data_type, SEXP object_names, SEXP as, SEXP path, SEXP path_type, SEXP n_records, SEXP verbose) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_query_con(cpp11::as_cpp<cpp11::decay_t<const sexp&>>(con), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path_type), cpp11::as_cpp<cpp11::decay_t<const double>>(n_records), cpp11::as_cpp<cpp11::decay_t<const bool>>(verbose)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_j_pivot(const std::vector<std::string>& data, const std::string& data_type, const std::string& object_names, const std::string& as, const std::string& path, const std::string& path_type);
extern "C" SEXP _rjsoncons_cpp_j_pivot(SEXP data, SEXP data_type, SEXP object_names, SEXP as, SEXP path, SEXP path_type) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_pivot(cpp11::as_cpp<cpp11::decay_t<const std::vector<std::string>&>>(data), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path_type)));
  END_CPP11
}
// rjsoncons.cpp
sexp cpp_j_pivot_con(const sexp& con, const std::string& data_type, const std::string& object_names, const std::string& as, const std::string& path, const std::string& path_type, const double n_records, const bool verbose);
extern "C" SEXP _rjsoncons_cpp_j_pivot_con(SEXP con, SEXP data_type, SEXP object_names, SEXP as, SEXP path, SEXP path_type, SEXP n_records, SEXP verbose) {
  BEGIN_CPP11
    return cpp11::as_sexp(cpp_j_pivot_con(cpp11::as_cpp<cpp11::decay_t<const sexp&>>(con), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(data_type), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(object_names), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(as), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path), cpp11::as_cpp<cpp11::decay_t<const std::string&>>(path_type), cpp11::as_cpp<cpp11::decay_t<const double>>(n_records), cpp11::as_cpp<cpp11::decay_t<const bool>>(verbose)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_rjsoncons_cpp_as_r",          (DL_FUNC) &_rjsoncons_cpp_as_r,          3},
    {"_rjsoncons_cpp_as_r_con",      (DL_FUNC) &_rjsoncons_cpp_as_r_con,      5},
    {"_rjsoncons_cpp_j_patch_apply", (DL_FUNC) &_rjsoncons_cpp_j_patch_apply, 4},
    {"_rjsoncons_cpp_j_patch_from",  (DL_FUNC) &_rjsoncons_cpp_j_patch_from,  5},
    {"_rjsoncons_cpp_j_pivot",       (DL_FUNC) &_rjsoncons_cpp_j_pivot,       6},
    {"_rjsoncons_cpp_j_pivot_con",   (DL_FUNC) &_rjsoncons_cpp_j_pivot_con,   8},
    {"_rjsoncons_cpp_j_query",       (DL_FUNC) &_rjsoncons_cpp_j_query,       6},
    {"_rjsoncons_cpp_j_query_con",   (DL_FUNC) &_rjsoncons_cpp_j_query_con,   8},
    {"_rjsoncons_cpp_version",       (DL_FUNC) &_rjsoncons_cpp_version,       0},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_rjsoncons(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
