#include <dragonruby.h>
#include <mruby/array.h>

static drb_api_t *drb_api;

static double add_all_rec(mrb_state *mrb, double acc, mrb_int argc, mrb_value *args) {
  double sum = acc;
  for (int i = 0; i < argc; i++) {
    mrb_value value = args[i];
    enum mrb_vtype type = mrb_type(value);
    if (type == MRB_TT_FLOAT) {
      sum += mrb_float(value);
    } else if (type == MRB_TT_FIXNUM) {
      sum += mrb_fixnum(value);
    } else if (type == MRB_TT_ARRAY) {
      sum = add_all_rec(mrb, sum, RARRAY_LEN(value), RARRAY_PTR(value));
    } else {
      drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), "Unsupported type");
    }
  }
  return sum;
}

static mrb_value add_all(mrb_state *mrb, mrb_value self) {
  mrb_value *args = 0;
  mrb_int argc = 0;
  drb_api->mrb_get_args(mrb, "*", &args, &argc);
  return drb_api->drb_float_value(mrb, add_all_rec(mrb, 0, argc, args));
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *state, struct drb_api_t *api) {
  drb_api = api;
  struct RClass *FFI = drb_api->mrb_module_get(state, "FFI");
  struct RClass *module = drb_api->mrb_define_module_under(state, FFI, "CExt");
  struct RClass *base = state->object_class;
  struct RClass *Adder = drb_api->mrb_define_class_under(state, module, "Adder", base);
  drb_api->mrb_define_method(state, Adder, "add_all", add_all, MRB_ARGS_REQ(1));
}
