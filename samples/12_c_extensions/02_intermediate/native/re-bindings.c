#include <mruby.h>
#include <string.h>
#include <assert.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include <dragonruby.h>
#include "app/re.h"

// MRuby `typedef`s mrb_int in the mruby/value.h
// Then `#define`s mrb_int in mruby.h
// We need to undo the macro and avoid it's usage
// FIXME: I'm surely doing something wrong
#ifdef mrb_int
#undef mrb_int
#endif

void *(*drb_symbol_lookup)(const char *sym) = NULL;

static void (*drb_free_foreign_object_f)(mrb_state *, void *);
static void (*drb_typecheck_float_f)(mrb_state *, mrb_value);
static void (*drb_typecheck_int_f)(mrb_state *, mrb_value);
static void (*drb_typecheck_bool_f)(mrb_state *, mrb_value);
static void (*drb_typecheck_aggregate_f)(mrb_state *, mrb_value, struct RClass *, mrb_data_type *);
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
static mrb_value (*drb_float_value_f)(mrb_state *, mrb_float);
static struct RClass *(*drb_getruntime_error_f)(mrb_state *);
static void drb_free_foreign_object_indirect(mrb_state *state, void *pointer) {
    drb_free_foreign_object_f(state, pointer);
}
static int drb_ffi__ZTSi_FromRuby(mrb_state *state, mrb_value self) {
    drb_typecheck_int_f(state, self);
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSi_ToRuby(mrb_state *state, int value) {
    return mrb_fixnum_value(value);
}
struct drb_foreign_object_ZTSP7regex_t {
    drb_foreign_object_kind kind;
    struct regex_t *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSP7regex_t = {"regex_t*", drb_free_foreign_object_indirect};
static struct regex_t *drb_ffi__ZTSP7regex_t_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Regex_tPointer");
    drb_typecheck_aggregate_f(state, self, klass, &ForeignObjectType_ZTSP7regex_t);
    return ((struct drb_foreign_object_ZTSP7regex_t *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSP7regex_t_ToRuby(mrb_state *state, struct regex_t *value) {
    struct drb_foreign_object_ZTSP7regex_t *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSP7regex_t));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "Regex_tPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSP7regex_t);
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
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "CharPointer");
    drb_typecheck_aggregate_f(state, self, klass, &ForeignObjectType_ZTSPc);
    return ((struct drb_foreign_object_ZTSPc *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPc_ToRuby(mrb_state *state, char *value) {
    struct drb_foreign_object_ZTSPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPc));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "CharPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPc);
    return mrb_obj_value(rdata);
}
struct drb_foreign_object_ZTSPi {
    drb_foreign_object_kind kind;
    int *value;
    int should_free;
};
static mrb_data_type ForeignObjectType_ZTSPi = {"int*", drb_free_foreign_object_indirect};
static int *drb_ffi__ZTSPi_FromRuby(mrb_state *state, mrb_value self) {
    if (mrb_nil_p(self))
        return 0;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "IntPointer");
    drb_typecheck_aggregate_f(state, self, klass, &ForeignObjectType_ZTSPi);
    return ((struct drb_foreign_object_ZTSPi *)DATA_PTR(self))->value;
}
static mrb_value drb_ffi__ZTSPi_ToRuby(mrb_state *state, int *value) {
    struct drb_foreign_object_ZTSPi *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPi));
    ptr->value = value;
    ptr->kind = drb_foreign_object_kind_pointer;
    struct RClass *FFI = mrb_module_get_f(state, "FFI");
    struct RClass *module = mrb_module_get_under_f(state, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(state, module, "IntPointer");
    struct RData *rdata = mrb_data_object_alloc_f(state, klass, ptr, &ForeignObjectType_ZTSPi);
    return mrb_obj_value(rdata);
}
static char drb_ffi__ZTSc_FromRuby(mrb_state *state, mrb_value self) {
    drb_typecheck_int_f(state, self);
    return mrb_fixnum(self);
}
static mrb_value drb_ffi__ZTSc_ToRuby(mrb_state *state, char value) {
    return mrb_fixnum_value(value);
}
static mrb_value drb_ffi__ZTSP7regex_t_New(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, drb_getruntime_error_f(mrb), "Cannot allocate pointer of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP7regex_t_GetValue(mrb_state *mrb, mrb_value value) {
    mrb_raise_f(mrb, drb_getruntime_error_f(mrb), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP7regex_t_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSP7regex_t_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSP7regex_t_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, drb_getruntime_error_f(mrb), "Cannot access value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSP7regex_t_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_raise_f(mrb, drb_getruntime_error_f(mrb), "Cannot change value of incomplete type");
    return mrb_nil_value();
}
static mrb_value drb_ffi__ZTSPc_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPc *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPc));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(char));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RE");
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
static mrb_value drb_ffi__ZTSPi_New(mrb_state *mrb, mrb_value self) {
    struct drb_foreign_object_ZTSPi *ptr = calloc(1, sizeof(struct drb_foreign_object_ZTSPi));
    ptr->kind = drb_foreign_object_kind_pointer;
    ptr->value = calloc(1, sizeof(int));
    ptr->should_free = 1;
    struct RClass *FFI = mrb_module_get_f(mrb, "FFI");
    struct RClass *module = mrb_module_get_under_f(mrb, FFI, "RE");
    struct RClass *klass = mrb_class_get_under_f(mrb, module, "IntPointer");
    struct RData *rdata = mrb_data_object_alloc_f(mrb, klass, ptr, &ForeignObjectType_ZTSPi);
    return mrb_obj_value(rdata);
}
static mrb_value drb_ffi__ZTSPi_GetValue(mrb_state *mrb, mrb_value value) {
    return drb_ffi__ZTSi_ToRuby(mrb, *drb_ffi__ZTSPi_FromRuby(mrb, value));
}
static mrb_value drb_ffi__ZTSPi_IsNil(mrb_state *state, mrb_value self) {
    if (drb_ffi__ZTSPi_FromRuby(state, self) == 0)
        return mrb_true_value();
    else
        return mrb_false_value();
}
static mrb_value drb_ffi__ZTSPi_GetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    return drb_ffi__ZTSi_ToRuby(mrb, drb_ffi__ZTSPi_FromRuby(mrb, self)[index]);
}
static mrb_value drb_ffi__ZTSPi_SetAt(mrb_state *mrb, mrb_value self) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(mrb, "*", &args, &argc);
    int index = drb_ffi__ZTSi_FromRuby(mrb, args[0]);
    int new_value = drb_ffi__ZTSi_FromRuby(mrb, args[1]);
    drb_ffi__ZTSPi_FromRuby(mrb, self)[index] = new_value;
    return mrb_nil_value();
}
static mrb_value drb_ffi_re_compile_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    char *pattern_0 = drb_ffi__ZTSPc_FromRuby(state, args[0]);
    struct regex_t *ret_val = re_compile(pattern_0);
    return drb_ffi__ZTSP7regex_t_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_re_matchp_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    struct regex_t *pattern_0 = drb_ffi__ZTSP7regex_t_FromRuby(state, args[0]);
    char *text_1 = drb_ffi__ZTSPc_FromRuby(state, args[1]);
    int *matchlength_2 = drb_ffi__ZTSPi_FromRuby(state, args[2]);
    int ret_val = re_matchp(pattern_0, text_1, matchlength_2);
    return drb_ffi__ZTSi_ToRuby(state, ret_val);
}
static mrb_value drb_ffi_re_match_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    char *pattern_0 = drb_ffi__ZTSPc_FromRuby(state, args[0]);
    char *text_1 = drb_ffi__ZTSPc_FromRuby(state, args[1]);
    int *matchlength_2 = drb_ffi__ZTSPi_FromRuby(state, args[2]);
    int ret_val = re_match(pattern_0, text_1, matchlength_2);
    return drb_ffi__ZTSi_ToRuby(state, ret_val);
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *));
DRB_FFI_EXPORT
void drb_register_c_extensions(void *(*lookup)(const char *), mrb_state *state, struct RClass *FFI) {
    if (drb_ffi_init_indirect_functions(lookup))
        return;
    struct RClass *module = mrb_define_module_under_f(state, FFI, "RE");
    struct RClass *object_class = state->object_class;
    mrb_define_module_function_f(state, module, "re_compile", drb_ffi_re_compile_Binding, MRB_ARGS_REQ(1));
    mrb_define_module_function_f(state, module, "re_matchp", drb_ffi_re_matchp_Binding, MRB_ARGS_REQ(3));
    mrb_define_module_function_f(state, module, "re_match", drb_ffi_re_match_Binding, MRB_ARGS_REQ(3));
    struct RClass *Regex_tPointerClass = mrb_define_class_under_f(state, module, "Regex_tPointer", object_class);
    mrb_define_class_method_f(state, Regex_tPointerClass, "new", drb_ffi__ZTSP7regex_t_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Regex_tPointerClass, "value", drb_ffi__ZTSP7regex_t_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, Regex_tPointerClass, "[]", drb_ffi__ZTSP7regex_t_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, Regex_tPointerClass, "[]=", drb_ffi__ZTSP7regex_t_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, Regex_tPointerClass, "nil?", drb_ffi__ZTSP7regex_t_IsNil, MRB_ARGS_REQ(0));
    struct RClass *CharPointerClass = mrb_define_class_under_f(state, module, "CharPointer", object_class);
    mrb_define_class_method_f(state, CharPointerClass, "new", drb_ffi__ZTSPc_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "value", drb_ffi__ZTSPc_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "[]", drb_ffi__ZTSPc_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, CharPointerClass, "[]=", drb_ffi__ZTSPc_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, CharPointerClass, "nil?", drb_ffi__ZTSPc_IsNil, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, CharPointerClass, "str", drb_ffi__ZTSPc_GetString, MRB_ARGS_REQ(0));
    struct RClass *IntPointerClass = mrb_define_class_under_f(state, module, "IntPointer", object_class);
    mrb_define_class_method_f(state, IntPointerClass, "new", drb_ffi__ZTSPi_New, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, IntPointerClass, "value", drb_ffi__ZTSPi_GetValue, MRB_ARGS_REQ(0));
    mrb_define_method_f(state, IntPointerClass, "[]", drb_ffi__ZTSPi_GetAt, MRB_ARGS_REQ(1));
    mrb_define_method_f(state, IntPointerClass, "[]=", drb_ffi__ZTSPi_SetAt, MRB_ARGS_REQ(2));
    mrb_define_method_f(state, IntPointerClass, "nil?", drb_ffi__ZTSPi_IsNil, MRB_ARGS_REQ(0));
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *fnname)) {
  drb_symbol_lookup = lookup;
  if (!(drb_float_value_f = (mrb_value (*)(mrb_state *, mrb_float)) lookup("drb_float_value"))) return -1;
  if (!(drb_free_foreign_object_f = (void (*)(mrb_state *, void *)) lookup("drb_free_foreign_object"))) return -1;
  if (!(drb_getruntime_error_f = (struct RClass *(*)(mrb_state *)) lookup("drb_getruntime_error"))) return -1;
  if (!(drb_typecheck_aggregate_f = (void (*)(mrb_state *, mrb_value, struct RClass *, mrb_data_type *)) lookup("drb_typecheck_aggregate"))) return -1;
  if (!(drb_typecheck_bool_f = (void (*)(mrb_state *, mrb_value)) lookup("drb_typecheck_bool"))) return -1;
  if (!(drb_typecheck_float_f = (void (*)(mrb_state *, mrb_value)) lookup("drb_typecheck_float"))) return -1;
  if (!(drb_typecheck_int_f = (void (*)(mrb_state *, mrb_value)) lookup("drb_typecheck_int"))) return -1;
  if (!(mrb_class_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_class_get_under"))) return -1;
  if (!(mrb_data_object_alloc_f = (struct RData *(*)(mrb_state *, struct RClass *, void *, const mrb_data_type *)) lookup("mrb_data_object_alloc"))) return -1;
  if (!(mrb_define_class_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_class_method"))) return -1;
  if (!(mrb_define_class_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *, struct RClass *)) lookup("mrb_define_class_under"))) return -1;
  if (!(mrb_define_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_method"))) return -1;
  if (!(mrb_define_module_function_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_module_function"))) return -1;
  if (!(mrb_define_module_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_define_module_under"))) return -1;
  if (!(mrb_get_args_f = (mrb_int (*)(mrb_state *, mrb_args_format, ...)) lookup("mrb_get_args"))) return -1;
  if (!(mrb_module_get_f = (struct RClass *(*)(mrb_state *, const char *)) lookup("mrb_module_get"))) return -1;
  if (!(mrb_module_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_module_get_under"))) return -1;
  if (!(mrb_raise_f = (void (*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_raise"))) return -1;
  if (!(mrb_str_new_cstr_f = (mrb_value (*)(mrb_state *, const char *)) lookup("mrb_str_new_cstr"))) return -1;
  return 0;
}
