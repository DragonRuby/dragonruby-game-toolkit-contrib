#include <mruby.h>
#include <string.h>
#include <assert.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include <dragonruby.h>
#include "regex-capi/include/rure.h"

// MRuby `typedef`s mrb_int in the mruby/value.h
// Then `#define`s mrb_int in mruby.h
// We need to undo the macro and avoid it's usage
// FIXME: I'm surely doing something wrong
#ifdef mrb_int
#undef mrb_int
#endif

void *(*drb_symbol_lookup)(const char *sym) = NULL;

static void (*drb_free_foreign_object_f)(mrb_state *, void *);
static struct RClass *(*mrb_module_get_f)(mrb_state *, const char *);
static mrb_int (*mrb_get_args_f)(mrb_state *, mrb_args_format, ...);
static struct RClass *(*mrb_module_get_under_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_class_get_under_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_define_module_under_f)(mrb_state *, struct RClass *, const char *);
static void (*mrb_define_module_function_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static struct RClass *(*mrb_define_class_under_f)(mrb_state *, struct RClass *, const char *, struct RClass *);
static void (*mrb_define_method_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static void (*mrb_define_class_method_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static struct RData *(*mrb_data_object_alloc_f)(mrb_state *, struct RClass *, void *, const mrb_data_type *);
static mrb_value (*mrb_str_new_cstr_f)(mrb_state *, const char *);
static void (*mrb_raise_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_exc_get_f)(mrb_state *, const char *);
static void drb_free_foreign_object_indirect(mrb_state *state, void *pointer) {
    drb_free_foreign_object_f(state, pointer);
}
struct drb_foreign_object_ZTSP4rure {
    drb_foreign_object_kind kind;
    rure *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP4rure = {"rure*", drb_free_foreign_object_indirect};
static rure *drb_ffi__ZTSP4rure_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP4rure *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP4rure_ToRuby(mrb_state *state, rure *value) {
    struct drb_foreign_object_ZTSP4rure *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP4rure));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "RurePointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP4rure);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPc {
    drb_foreign_object_kind kind;
    char *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPc = {"char*", drb_free_foreign_object_indirect};
static char *drb_ffi__ZTSPc_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    if (mrb_type(self) == MRB_TT_STRING)
        return RSTRING_PTR(self);
    return ((struct drb_foreign_object_ZTSPc *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPc_ToRuby(mrb_state *state, char *value) {
    struct drb_foreign_object_ZTSPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPc));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "CharPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPc);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPh {
    drb_foreign_object_kind kind;
    uint8_t *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPh = {"unsigned char*", drb_free_foreign_object_indirect};
static uint8_t *drb_ffi__ZTSPh_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    if (mrb_type(self) == MRB_TT_STRING)
        return RSTRING_PTR(self);
    return ((struct drb_foreign_object_ZTSPh *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPh_ToRuby(mrb_state *state, uint8_t *value) {
    struct drb_foreign_object_ZTSPh *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPh));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Unsigned_charPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPh);
    return mrb_obj_value(rdata);
}
static size_t drb_ffi__ZTSm_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSm_ToRuby(mrb_state *state, size_t value) {
    return mrb_fixnum_value(value);
}
static uint32_t drb_ffi__ZTSj_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSj_ToRuby(mrb_state *state, uint32_t value) {
    return mrb_fixnum_value(value);
}
struct drb_foreign_object_ZTSP12rure_options {
    drb_foreign_object_kind kind;
    rure_options *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP12rure_options = {"rure_options*", drb_free_foreign_object_indirect};
static rure_options *drb_ffi__ZTSP12rure_options_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP12rure_options *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP12rure_options_ToRuby(mrb_state *state, rure_options *value) {
    struct drb_foreign_object_ZTSP12rure_options *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP12rure_options));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_optionsPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP12rure_options);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSP10rure_error {
    drb_foreign_object_kind kind;
    rure_error *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP10rure_error = {"rure_error*", drb_free_foreign_object_indirect};
static rure_error *drb_ffi__ZTSP10rure_error_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP10rure_error *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP10rure_error_ToRuby(mrb_state *state, rure_error *value) {
    struct drb_foreign_object_ZTSP10rure_error *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP10rure_error));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_errorPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP10rure_error);
    return mrb_obj_value(rdata);
}
static bool drb_ffi__ZTSb_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSb_ToRuby(mrb_state *state, bool value) {
    return mrb_fixnum_value(value);
}
struct drb_foreign_object_ZTSP10rure_match {
    drb_foreign_object_kind kind;
    rure_match *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP10rure_match = {"rure_match*", drb_free_foreign_object_indirect};
static rure_match *drb_ffi__ZTSP10rure_match_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP10rure_match *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP10rure_match_ToRuby(mrb_state *state, rure_match *value) {
    struct drb_foreign_object_ZTSP10rure_match *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP10rure_match));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_matchPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP10rure_match);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSP13rure_captures {
    drb_foreign_object_kind kind;
    rure_captures *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP13rure_captures = {"rure_captures*", drb_free_foreign_object_indirect};
static rure_captures *drb_ffi__ZTSP13rure_captures_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP13rure_captures *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP13rure_captures_ToRuby(mrb_state *state, rure_captures *value) {
    struct drb_foreign_object_ZTSP13rure_captures *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP13rure_captures));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_capturesPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP13rure_captures);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPm {
    drb_foreign_object_kind kind;
    size_t *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPm = {"unsigned long*", drb_free_foreign_object_indirect};
static size_t *drb_ffi__ZTSPm_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSPm *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPm_ToRuby(mrb_state *state, size_t *value) {
    struct drb_foreign_object_ZTSPm *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPm));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Unsigned_longPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPm);
    return mrb_obj_value(rdata);
}
static int32_t drb_ffi__ZTSi_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSi_ToRuby(mrb_state *state, int32_t value) {
    return mrb_fixnum_value(value);
}
struct drb_foreign_object_ZTSP23rure_iter_capture_names {
    drb_foreign_object_kind kind;
    rure_iter_capture_names *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP23rure_iter_capture_names = {"rure_iter_capture_names*", drb_free_foreign_object_indirect};
static rure_iter_capture_names *drb_ffi__ZTSP23rure_iter_capture_names_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP23rure_iter_capture_names *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_ToRuby(mrb_state *state, rure_iter_capture_names *value) {
    struct drb_foreign_object_ZTSP23rure_iter_capture_names *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP23rure_iter_capture_names));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_iter_capture_namesPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP23rure_iter_capture_names);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPPc {
    drb_foreign_object_kind kind;
    char **value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPPc = {"char**", drb_free_foreign_object_indirect};
static char **drb_ffi__ZTSPPc_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSPPc *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPPc_ToRuby(mrb_state *state, char **value) {
    struct drb_foreign_object_ZTSPPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPPc));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "CharPointerPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPPc);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSP9rure_iter {
    drb_foreign_object_kind kind;
    rure_iter *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP9rure_iter = {"rure_iter*", drb_free_foreign_object_indirect};
static rure_iter *drb_ffi__ZTSP9rure_iter_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP9rure_iter *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP9rure_iter_ToRuby(mrb_state *state, rure_iter *value) {
    struct drb_foreign_object_ZTSP9rure_iter *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP9rure_iter));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_iterPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP9rure_iter);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSP8rure_set {
    drb_foreign_object_kind kind;
    rure_set *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP8rure_set = {"rure_set*", drb_free_foreign_object_indirect};
static rure_set *drb_ffi__ZTSP8rure_set_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSP8rure_set *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP8rure_set_ToRuby(mrb_state *state, rure_set *value) {
    struct drb_foreign_object_ZTSP8rure_set *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP8rure_set));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_setPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP8rure_set);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPPh {
    drb_foreign_object_kind kind;
    uint8_t **value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPPh = {"unsigned char**", drb_free_foreign_object_indirect};
static uint8_t **drb_ffi__ZTSPPh_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSPPh *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPPh_ToRuby(mrb_state *state, uint8_t **value) {
    struct drb_foreign_object_ZTSPPh *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPPh));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Unsigned_charPointerPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPPh);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPb {
    drb_foreign_object_kind kind;
    bool *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPb = {"_Bool*", drb_free_foreign_object_indirect};
static bool *drb_ffi__ZTSPb_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    return ((struct drb_foreign_object_ZTSPb *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPb_ToRuby(mrb_state *state, bool *value) {
    struct drb_foreign_object_ZTSPb *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPb));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "_BoolPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPb);
    return mrb_obj_value(rdata);
}
static char drb_ffi__ZTSc_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSc_ToRuby(mrb_state *state, char value) {
    return mrb_fixnum_value(value);
}
static uint8_t drb_ffi__ZTSh_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSh_ToRuby(mrb_state *state, uint8_t value) {
    return mrb_fixnum_value(value);
}
struct drb_foreign_object_ZTS10rure_match {
    drb_foreign_object_kind kind;
    rure_match value;
};
static mrb_data_type ForeignObjectType_ZTS10rure_match = {"rure_match", drb_free_foreign_object_indirect};
static rure_match drb_ffi__ZTS10rure_match_FromRuby(mrb_state *state, mrb_value self) {
    return ((struct drb_foreign_object_ZTS10rure_match *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTS10rure_match_ToRuby(mrb_state *state, rure_match value) {
    struct drb_foreign_object_ZTS10rure_match *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTS10rure_match));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_struct;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_match");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTS10rure_match);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSP4rure_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP4rure_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP4rure_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP4rure_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP4rure_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP4rure_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPc_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPc));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(char));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "CharPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPc);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPc_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSc_ToRuby(mrb, *drb_ffi__ZTSPc_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPc_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPc_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPc_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSc_ToRuby(mrb, drb_ffi__ZTSPc_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPc_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    char new_value = drb_ffi__ZTSc_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPc_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPc_GetString(mrb_state *state, mrb_value self) {
    return mrb_str_new_cstr_f(state, drb_ffi__ZTSPc_FromRuby(state, self));
}
static mrb_value drb_ffi__ZTSPh_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPh *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPh));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(uint8_t));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "Unsigned_charPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPh);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPh_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSh_ToRuby(mrb, *drb_ffi__ZTSPh_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPh_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPh_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPh_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSh_ToRuby(mrb, drb_ffi__ZTSPh_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPh_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    uint8_t new_value = drb_ffi__ZTSh_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPh_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPh_GetString(mrb_state *state, mrb_value self) {
    return mrb_str_new_cstr_f(state, drb_ffi__ZTSPh_FromRuby(state, self));
}
static mrb_value drb_ffi__ZTSP12rure_options_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP12rure_options_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP12rure_options_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP12rure_options_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP12rure_options_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP12rure_options_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP10rure_error_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP10rure_error_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP10rure_error_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP10rure_error_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP10rure_error_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP10rure_error_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP10rure_match_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSP10rure_match *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP10rure_match));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(rure_match));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "Rure_matchPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSP10rure_match);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSP10rure_match_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTS10rure_match_ToRuby(mrb, *drb_ffi__ZTSP10rure_match_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSP10rure_match_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP10rure_match_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP10rure_match_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTS10rure_match_ToRuby(mrb, drb_ffi__ZTSP10rure_match_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSP10rure_match_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    rure_match new_value = drb_ffi__ZTS10rure_match_FromRuby(mrb, args[1]);
    drb_ffi__ZTSP10rure_match_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP13rure_captures_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP13rure_captures_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP13rure_captures_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP13rure_captures_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP13rure_captures_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP13rure_captures_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPm_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPm *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPm));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(size_t));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "Unsigned_longPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPm);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPm_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSm_ToRuby(mrb, *drb_ffi__ZTSPm_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPm_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPm_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPm_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSm_ToRuby(mrb, drb_ffi__ZTSPm_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPm_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    size_t new_value = drb_ffi__ZTSm_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPm_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP23rure_iter_capture_names_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP23rure_iter_capture_names_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPPc_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPPc));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(char *));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "CharPointerPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPPc);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPPc_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSPc_ToRuby(mrb, *drb_ffi__ZTSPPc_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPPc_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPPc_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPPc_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSPc_ToRuby(mrb, drb_ffi__ZTSPPc_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPPc_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    char *new_value = drb_ffi__ZTSPc_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPPc_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP9rure_iter_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP9rure_iter_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP9rure_iter_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP9rure_iter_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP9rure_iter_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP9rure_iter_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP8rure_set_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP8rure_set_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP8rure_set_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP8rure_set_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP8rure_set_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP8rure_set_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, mrb_exc_get_f(mrb, "RuntimeError"), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPPh_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPPh *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPPh));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(uint8_t *));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "Unsigned_charPointerPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPPh);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPPh_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSPh_ToRuby(mrb, *drb_ffi__ZTSPPh_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPPh_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPPh_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPPh_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSPh_ToRuby(mrb, drb_ffi__ZTSPPh_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPPh_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    uint8_t *new_value = drb_ffi__ZTSPh_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPPh_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPb_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPb *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPb));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(bool));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "_BoolPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPb);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPb_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSb_ToRuby(mrb, *drb_ffi__ZTSPb_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPb_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPb_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPb_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSb_ToRuby(mrb, drb_ffi__ZTSPb_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPb_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    bool new_value = drb_ffi__ZTSb_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPb_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTS10rure_match_New(mrb_state *state, mrb_value self) {
    struct drb_foreign_object_ZTS10rure_match *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTS10rure_match *));
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RURE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Rure_match");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTS10rure_match);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTS10rure_match_start_Get(mrb_state *state, mrb_value self) {
    rure_match record = drb_ffi__ZTS10rure_match_FromRuby(state, self);
    return drb_ffi__ZTSm_ToRuby(state, record.start);
}
static mrb_value drb_ffi__ZTS10rure_match_start_Set(mrb_state *state, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    size_t new_value = drb_ffi__ZTSm_FromRuby(state, args[0]);
    (&((struct drb_foreign_object_ZTS10rure_match *)DATA_PTR(self))->value)->start = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTS10rure_match_end_Get(mrb_state *state, mrb_value self) {
    rure_match record = drb_ffi__ZTS10rure_match_FromRuby(state, self);
    return drb_ffi__ZTSm_ToRuby(state, record.end);
}
static mrb_value drb_ffi__ZTS10rure_match_end_Set(mrb_state *state, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    size_t new_value = drb_ffi__ZTSm_FromRuby(state, args[0]);
    (&((struct drb_foreign_object_ZTS10rure_match *)DATA_PTR(self))->value)->end = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_compile_must_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    char *pattern_0 = drb_ffi__ZTSPc_FromRuby(state, args[0]);
    rure *ret_val = rure_compile_must(pattern_0);
    return drb_ffi__ZTSP4rure_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_compile_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    uint8_t *pattern_0 = drb_ffi__ZTSPh_FromRuby(state, args[0]);
    size_t length_1 = drb_ffi__ZTSm_FromRuby(state, args[1]);
    uint32_t flags_2 = drb_ffi__ZTSj_FromRuby(state, args[2]);
    rure_options *options_3 = drb_ffi__ZTSP12rure_options_FromRuby(state, args[3]);
    rure_error *error_4 = drb_ffi__ZTSP10rure_error_FromRuby(state, args[4]);
    rure *ret_val = rure_compile(pattern_0, length_1, flags_2, options_3, error_4);
    return drb_ffi__ZTSP4rure_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    rure_free(re_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_is_match_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    bool ret_val = rure_is_match(re_0, haystack_1, length_2, start_3);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_find_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    rure_match *match_4 = drb_ffi__ZTSP10rure_match_FromRuby(state, args[4]);
    bool ret_val = rure_find(re_0, haystack_1, length_2, start_3, match_4);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_find_captures_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    rure_captures *captures_4 = drb_ffi__ZTSP13rure_captures_FromRuby(state, args[4]);
    bool ret_val = rure_find_captures(re_0, haystack_1, length_2, start_3, captures_4);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_shortest_match_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    size_t *end_4 = drb_ffi__ZTSPm_FromRuby(state, args[4]);
    bool ret_val = rure_shortest_match(re_0, haystack_1, length_2, start_3, end_4);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_capture_name_index_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    char *name_1 = drb_ffi__ZTSPc_FromRuby(state, args[1]);
    int32_t ret_val = rure_capture_name_index(re_0, name_1);
    return drb_ffi__ZTSi_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_iter_capture_names_new_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    rure_iter_capture_names *ret_val = rure_iter_capture_names_new(re_0);
    return drb_ffi__ZTSP23rure_iter_capture_names_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_iter_capture_names_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_iter_capture_names *it_0 = drb_ffi__ZTSP23rure_iter_capture_names_FromRuby(state, args[0]);
    rure_iter_capture_names_free(it_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_iter_capture_names_next_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_iter_capture_names *it_0 = drb_ffi__ZTSP23rure_iter_capture_names_FromRuby(state, args[0]);
    char **name_1 = drb_ffi__ZTSPPc_FromRuby(state, args[1]);
    bool ret_val = rure_iter_capture_names_next(it_0, name_1);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_iter_new_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    rure_iter *ret_val = rure_iter_new(re_0);
    return drb_ffi__ZTSP9rure_iter_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_iter_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_iter *it_0 = drb_ffi__ZTSP9rure_iter_FromRuby(state, args[0]);
    rure_iter_free(it_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_iter_next_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_iter *it_0 = drb_ffi__ZTSP9rure_iter_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    rure_match *match_3 = drb_ffi__ZTSP10rure_match_FromRuby(state, args[3]);
    bool ret_val = rure_iter_next(it_0, haystack_1, length_2, match_3);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_iter_next_captures_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_iter *it_0 = drb_ffi__ZTSP9rure_iter_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    rure_captures *captures_3 = drb_ffi__ZTSP13rure_captures_FromRuby(state, args[3]);
    bool ret_val = rure_iter_next_captures(it_0, haystack_1, length_2, captures_3);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_captures_new_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure *re_0 = drb_ffi__ZTSP4rure_FromRuby(state, args[0]);
    rure_captures *ret_val = rure_captures_new(re_0);
    return drb_ffi__ZTSP13rure_captures_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_captures_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_captures *captures_0 = drb_ffi__ZTSP13rure_captures_FromRuby(state, args[0]);
    rure_captures_free(captures_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_captures_at_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_captures *captures_0 = drb_ffi__ZTSP13rure_captures_FromRuby(state, args[0]);
    size_t i_1 = drb_ffi__ZTSm_FromRuby(state, args[1]);
    rure_match *match_2 = drb_ffi__ZTSP10rure_match_FromRuby(state, args[2]);
    bool ret_val = rure_captures_at(captures_0, i_1, match_2);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_captures_len_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_captures *captures_0 = drb_ffi__ZTSP13rure_captures_FromRuby(state, args[0]);
    size_t ret_val = rure_captures_len(captures_0);
    return drb_ffi__ZTSm_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_options_new_Binding(mrb_state *state, mrb_value value) {
    rure_options *ret_val = rure_options_new();
    return drb_ffi__ZTSP12rure_options_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_options_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_options *options_0 = drb_ffi__ZTSP12rure_options_FromRuby(state, args[0]);
    rure_options_free(options_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_options_size_limit_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_options *options_0 = drb_ffi__ZTSP12rure_options_FromRuby(state, args[0]);
    size_t limit_1 = drb_ffi__ZTSm_FromRuby(state, args[1]);
    rure_options_size_limit(options_0, limit_1);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_options_dfa_size_limit_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_options *options_0 = drb_ffi__ZTSP12rure_options_FromRuby(state, args[0]);
    size_t limit_1 = drb_ffi__ZTSm_FromRuby(state, args[1]);
    rure_options_dfa_size_limit(options_0, limit_1);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_compile_set_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    uint8_t **patterns_0 = drb_ffi__ZTSPPh_FromRuby(state, args[0]);
    size_t *patterns_lengths_1 = drb_ffi__ZTSPm_FromRuby(state, args[1]);
    size_t patterns_count_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    uint32_t flags_3 = drb_ffi__ZTSj_FromRuby(state, args[3]);
    rure_options *options_4 = drb_ffi__ZTSP12rure_options_FromRuby(state, args[4]);
    rure_error *error_5 = drb_ffi__ZTSP10rure_error_FromRuby(state, args[5]);
    rure_set *ret_val = rure_compile_set(patterns_0, patterns_lengths_1, patterns_count_2, flags_3, options_4, error_5);
    return drb_ffi__ZTSP8rure_set_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_set_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_set *re_0 = drb_ffi__ZTSP8rure_set_FromRuby(state, args[0]);
    rure_set_free(re_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_set_is_match_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_set *re_0 = drb_ffi__ZTSP8rure_set_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    bool ret_val = rure_set_is_match(re_0, haystack_1, length_2, start_3);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_set_matches_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_set *re_0 = drb_ffi__ZTSP8rure_set_FromRuby(state, args[0]);
    uint8_t *haystack_1 = drb_ffi__ZTSPh_FromRuby(state, args[1]);
    size_t length_2 = drb_ffi__ZTSm_FromRuby(state, args[2]);
    size_t start_3 = drb_ffi__ZTSm_FromRuby(state, args[3]);
    bool *matches_4 = drb_ffi__ZTSPb_FromRuby(state, args[4]);
    bool ret_val = rure_set_matches(re_0, haystack_1, length_2, start_3, matches_4);
    return drb_ffi__ZTSb_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_set_len_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_set *re_0 = drb_ffi__ZTSP8rure_set_FromRuby(state, args[0]);
    size_t ret_val = rure_set_len(re_0);
    return drb_ffi__ZTSm_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_error_new_Binding(mrb_state *state, mrb_value value) {
    rure_error *ret_val = rure_error_new();
    return drb_ffi__ZTSP10rure_error_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_error_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_error *err_0 = drb_ffi__ZTSP10rure_error_FromRuby(state, args[0]);
    rure_error_free(err_0);
    return mrb_nil_value();
}
static mrb_value drb_ffi_rure_error_message_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    rure_error *err_0 = drb_ffi__ZTSP10rure_error_FromRuby(state, args[0]);
    char *ret_val = rure_error_message(err_0);
    return drb_ffi__ZTSPc_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_escape_must_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    char *pattern_0 = drb_ffi__ZTSPc_FromRuby(state, args[0]);
    char *ret_val = rure_escape_must(pattern_0);
    return drb_ffi__ZTSPc_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_rure_cstring_free_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    char *s_0 = drb_ffi__ZTSPc_FromRuby(state, args[0]);
    rure_cstring_free(s_0);
    return mrb_nil_value();
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *));
DRB_FFI_EXPORT
void drb_register_c_extensions(void *(*lookup)(const char *), mrb_state *state, struct RClass *FFI) {
    if (drb_ffi_init_indirect_functions(lookup))
        return;
    struct RClass *module = mrb_define_module_under_f(state, FFI, "RURE");
    struct RClass *object_class = state->object_class;
    mrb_define_module_function_f(state, module, "rure_compile_must", drb_ffi_rure_compile_must_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_compile", drb_ffi_rure_compile_Binding, MRB_ARGS_REQ(5));
    mrb_define_module_function_f(state, module, "rure_free", drb_ffi_rure_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_is_match", drb_ffi_rure_is_match_Binding, MRB_ARGS_REQ(4));
    mrb_define_module_function_f(state, module, "rure_find", drb_ffi_rure_find_Binding, MRB_ARGS_REQ(5));
    mrb_define_module_function_f(state, module, "rure_find_captures", drb_ffi_rure_find_captures_Binding, MRB_ARGS_REQ(5));
    mrb_define_module_function_f(state, module, "rure_shortest_match", drb_ffi_rure_shortest_match_Binding, MRB_ARGS_REQ(5));
    mrb_define_module_function_f(state, module, "rure_capture_name_index", drb_ffi_rure_capture_name_index_Binding, MRB_ARGS_REQ(2));
    mrb_define_module_function_f(state, module, "rure_iter_capture_names_new", drb_ffi_rure_iter_capture_names_new_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_iter_capture_names_free", drb_ffi_rure_iter_capture_names_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_iter_capture_names_next", drb_ffi_rure_iter_capture_names_next_Binding, MRB_ARGS_REQ(2));
    mrb_define_module_function_f(state, module, "rure_iter_new", drb_ffi_rure_iter_new_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_iter_free", drb_ffi_rure_iter_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_iter_next", drb_ffi_rure_iter_next_Binding, MRB_ARGS_REQ(4));
    mrb_define_module_function_f(state, module, "rure_iter_next_captures", drb_ffi_rure_iter_next_captures_Binding, MRB_ARGS_REQ(4));
    mrb_define_module_function_f(state, module, "rure_captures_new", drb_ffi_rure_captures_new_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_captures_free", drb_ffi_rure_captures_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_captures_at", drb_ffi_rure_captures_at_Binding, MRB_ARGS_REQ(3));
    mrb_define_module_function_f(state, module, "rure_captures_len", drb_ffi_rure_captures_len_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_options_new", drb_ffi_rure_options_new_Binding, MRB_ARGS_REQ(0));
    mrb_define_module_function_f(state, module, "rure_options_free", drb_ffi_rure_options_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_options_size_limit", drb_ffi_rure_options_size_limit_Binding, MRB_ARGS_REQ(2));
    mrb_define_module_function_f(state, module, "rure_options_dfa_size_limit", drb_ffi_rure_options_dfa_size_limit_Binding, MRB_ARGS_REQ(2));
    mrb_define_module_function_f(state, module, "rure_compile_set", drb_ffi_rure_compile_set_Binding, MRB_ARGS_REQ(6));
    mrb_define_module_function_f(state, module, "rure_set_free", drb_ffi_rure_set_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_set_is_match", drb_ffi_rure_set_is_match_Binding, MRB_ARGS_REQ(4));
    mrb_define_module_function_f(state, module, "rure_set_matches", drb_ffi_rure_set_matches_Binding, MRB_ARGS_REQ(5));
    mrb_define_module_function_f(state, module, "rure_set_len", drb_ffi_rure_set_len_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_error_new", drb_ffi_rure_error_new_Binding, MRB_ARGS_REQ(0));
    mrb_define_module_function_f(state, module, "rure_error_free", drb_ffi_rure_error_free_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_error_message", drb_ffi_rure_error_message_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_escape_must", drb_ffi_rure_escape_must_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "rure_cstring_free", drb_ffi_rure_cstring_free_Binding, MRB_ARGS_REQ(1));
    struct RClass *RurePointerClass = mrb_define_class_under_f(state, module, "RurePointer", object_class);
    mrb_define_class_method_f(state, RurePointerClass, "new", drb_ffi__ZTSP4rure_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, RurePointerClass, "value", drb_ffi__ZTSP4rure_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, RurePointerClass, "[]", drb_ffi__ZTSP4rure_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, RurePointerClass, "[]=", drb_ffi__ZTSP4rure_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, RurePointerClass, "nil?", drb_ffi__ZTSP4rure_IsNil, MRB_ARGS_REQ(0));
    struct RClass *CharPointerClass = mrb_define_class_under_f(state, module, "CharPointer", object_class);
    mrb_define_class_method_f(state, CharPointerClass, "new", drb_ffi__ZTSPc_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "value", drb_ffi__ZTSPc_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "[]", drb_ffi__ZTSPc_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, CharPointerClass, "[]=", drb_ffi__ZTSPc_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, CharPointerClass, "nil?", drb_ffi__ZTSPc_IsNil, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "str", drb_ffi__ZTSPc_GetString, MRB_ARGS_REQ(0));
    struct RClass *Unsigned_charPointerClass = mrb_define_class_under_f(state, module, "Unsigned_charPointer", object_class);
    mrb_define_class_method_f(state, Unsigned_charPointerClass, "new", drb_ffi__ZTSPh_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_charPointerClass, "value", drb_ffi__ZTSPh_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_charPointerClass, "[]", drb_ffi__ZTSPh_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Unsigned_charPointerClass, "[]=", drb_ffi__ZTSPh_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Unsigned_charPointerClass, "nil?", drb_ffi__ZTSPh_IsNil, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_charPointerClass, "str", drb_ffi__ZTSPh_GetString, MRB_ARGS_REQ(0));
    struct RClass *Rure_optionsPointerClass = mrb_define_class_under_f(state, module, "Rure_optionsPointer", object_class);
    mrb_define_class_method_f(state, Rure_optionsPointerClass, "new", drb_ffi__ZTSP12rure_options_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_optionsPointerClass, "value", drb_ffi__ZTSP12rure_options_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_optionsPointerClass, "[]", drb_ffi__ZTSP12rure_options_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_optionsPointerClass, "[]=", drb_ffi__ZTSP12rure_options_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_optionsPointerClass, "nil?", drb_ffi__ZTSP12rure_options_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_errorPointerClass = mrb_define_class_under_f(state, module, "Rure_errorPointer", object_class);
    mrb_define_class_method_f(state, Rure_errorPointerClass, "new", drb_ffi__ZTSP10rure_error_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_errorPointerClass, "value", drb_ffi__ZTSP10rure_error_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_errorPointerClass, "[]", drb_ffi__ZTSP10rure_error_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_errorPointerClass, "[]=", drb_ffi__ZTSP10rure_error_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_errorPointerClass, "nil?", drb_ffi__ZTSP10rure_error_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_matchPointerClass = mrb_define_class_under_f(state, module, "Rure_matchPointer", object_class);
    mrb_define_class_method_f(state, Rure_matchPointerClass, "new", drb_ffi__ZTSP10rure_match_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_matchPointerClass, "value", drb_ffi__ZTSP10rure_match_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_matchPointerClass, "[]", drb_ffi__ZTSP10rure_match_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_matchPointerClass, "[]=", drb_ffi__ZTSP10rure_match_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_matchPointerClass, "nil?", drb_ffi__ZTSP10rure_match_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_capturesPointerClass = mrb_define_class_under_f(state, module, "Rure_capturesPointer", object_class);
    mrb_define_class_method_f(state, Rure_capturesPointerClass, "new", drb_ffi__ZTSP13rure_captures_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_capturesPointerClass, "value", drb_ffi__ZTSP13rure_captures_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_capturesPointerClass, "[]", drb_ffi__ZTSP13rure_captures_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_capturesPointerClass, "[]=", drb_ffi__ZTSP13rure_captures_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_capturesPointerClass, "nil?", drb_ffi__ZTSP13rure_captures_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Unsigned_longPointerClass = mrb_define_class_under_f(state, module, "Unsigned_longPointer", object_class);
    mrb_define_class_method_f(state, Unsigned_longPointerClass, "new", drb_ffi__ZTSPm_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_longPointerClass, "value", drb_ffi__ZTSPm_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_longPointerClass, "[]", drb_ffi__ZTSPm_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Unsigned_longPointerClass, "[]=", drb_ffi__ZTSPm_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Unsigned_longPointerClass, "nil?", drb_ffi__ZTSPm_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_iter_capture_namesPointerClass = mrb_define_class_under_f(state, module, "Rure_iter_capture_namesPointer", object_class);
    mrb_define_class_method_f(state, Rure_iter_capture_namesPointerClass, "new", drb_ffi__ZTSP23rure_iter_capture_names_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_iter_capture_namesPointerClass, "value", drb_ffi__ZTSP23rure_iter_capture_names_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_iter_capture_namesPointerClass, "[]", drb_ffi__ZTSP23rure_iter_capture_names_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_iter_capture_namesPointerClass, "[]=", drb_ffi__ZTSP23rure_iter_capture_names_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_iter_capture_namesPointerClass, "nil?", drb_ffi__ZTSP23rure_iter_capture_names_IsNil, MRB_ARGS_REQ(0));
    struct RClass *CharPointerPointerClass = mrb_define_class_under_f(state, module, "CharPointerPointer", object_class);
    mrb_define_class_method_f(state, CharPointerPointerClass, "new", drb_ffi__ZTSPPc_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerPointerClass, "value", drb_ffi__ZTSPPc_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerPointerClass, "[]", drb_ffi__ZTSPPc_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, CharPointerPointerClass, "[]=", drb_ffi__ZTSPPc_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, CharPointerPointerClass, "nil?", drb_ffi__ZTSPPc_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_iterPointerClass = mrb_define_class_under_f(state, module, "Rure_iterPointer", object_class);
    mrb_define_class_method_f(state, Rure_iterPointerClass, "new", drb_ffi__ZTSP9rure_iter_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_iterPointerClass, "value", drb_ffi__ZTSP9rure_iter_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_iterPointerClass, "[]", drb_ffi__ZTSP9rure_iter_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_iterPointerClass, "[]=", drb_ffi__ZTSP9rure_iter_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_iterPointerClass, "nil?", drb_ffi__ZTSP9rure_iter_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_setPointerClass = mrb_define_class_under_f(state, module, "Rure_setPointer", object_class);
    mrb_define_class_method_f(state, Rure_setPointerClass, "new", drb_ffi__ZTSP8rure_set_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_setPointerClass, "value", drb_ffi__ZTSP8rure_set_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_setPointerClass, "[]", drb_ffi__ZTSP8rure_set_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_setPointerClass, "[]=", drb_ffi__ZTSP8rure_set_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Rure_setPointerClass, "nil?", drb_ffi__ZTSP8rure_set_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Unsigned_charPointerPointerClass = mrb_define_class_under_f(state, module, "Unsigned_charPointerPointer", object_class);
    mrb_define_class_method_f(state, Unsigned_charPointerPointerClass, "new", drb_ffi__ZTSPPh_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_charPointerPointerClass, "value", drb_ffi__ZTSPPh_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Unsigned_charPointerPointerClass, "[]", drb_ffi__ZTSPPh_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Unsigned_charPointerPointerClass, "[]=", drb_ffi__ZTSPPh_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Unsigned_charPointerPointerClass, "nil?", drb_ffi__ZTSPPh_IsNil, MRB_ARGS_REQ(0));
    struct RClass *_BoolPointerClass = mrb_define_class_under_f(state, module, "_BoolPointer", object_class);
    mrb_define_class_method_f(state, _BoolPointerClass, "new", drb_ffi__ZTSPb_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, _BoolPointerClass, "value", drb_ffi__ZTSPb_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, _BoolPointerClass, "[]", drb_ffi__ZTSPb_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, _BoolPointerClass, "[]=", drb_ffi__ZTSPb_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, _BoolPointerClass, "nil?", drb_ffi__ZTSPb_IsNil, MRB_ARGS_REQ(0));
    struct RClass *Rure_matchClass = mrb_define_class_under_f(state, module, "Rure_match", object_class);
    mrb_define_class_method_f(state, Rure_matchClass, "new", drb_ffi__ZTS10rure_match_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_matchClass, "start", drb_ffi__ZTS10rure_match_start_Get, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_matchClass, "start=", drb_ffi__ZTS10rure_match_start_Set, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Rure_matchClass, "end", drb_ffi__ZTS10rure_match_end_Get, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Rure_matchClass, "end=", drb_ffi__ZTS10rure_match_end_Set, MRB_ARGS_REQ(1));
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *fnname)) {
  drb_symbol_lookup = lookup;
  if (!(drb_free_foreign_object_f = (void (*)(mrb_state *, void *)) lookup("drb_free_foreign_object"))) return -1;
  if (!(mrb_class_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_class_get_under"))) return -1;
  if (!(mrb_data_object_alloc_f = (struct RData *(*)(mrb_state *, struct RClass *, void *, const mrb_data_type *)) lookup("mrb_data_object_alloc"))) return -1;
  if (!(mrb_define_class_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_class_method"))) return -1;
  if (!(mrb_define_class_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *, struct RClass *)) lookup("mrb_define_class_under"))) return -1;
  if (!(mrb_define_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_method"))) return -1;
  if (!(mrb_define_module_function_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_module_function"))) return -1;
  if (!(mrb_define_module_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_define_module_under"))) return -1;
  if (!(mrb_exc_get_f = (struct RClass *(*)(mrb_state *, const char *)) lookup("mrb_exc_get"))) return -1;
  if (!(mrb_get_args_f = (mrb_int (*)(mrb_state *, mrb_args_format, ...)) lookup("mrb_get_args"))) return -1;
  if (!(mrb_module_get_f = (struct RClass *(*)(mrb_state *, const char *)) lookup("mrb_module_get"))) return -1;
  if (!(mrb_module_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_module_get_under"))) return -1;
  if (!(mrb_raise_f = (void (*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_raise"))) return -1;
  if (!(mrb_str_new_cstr_f = (mrb_value (*)(mrb_state *, const char *)) lookup("mrb_str_new_cstr"))) return -1;
  return 0;
}
