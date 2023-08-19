#include <dragonruby.h>
#include <mruby.h>
#include <mruby/array.h>
#include <mruby/hash.h>
#include <time.h>
#include <stdlib.h>

#undef mrb_float
#undef Data_Wrap_Struct
#undef Data_Make_Struct
#undef Data_Get_Struct

struct RFloat {
  MRB_OBJECT_HEADER;
  mrb_float f;
};

union drb_value_ {
  void *p;
#ifdef MRB_64BIT
  /* use struct to avoid bit shift. */
  struct {
    MRB_ENDIAN_LOHI(
      mrb_sym sym;
      ,uint32_t sym_flag;
    )
  };
#endif
  struct RBasic *bp;
#ifndef MRB_NO_FLOAT
  struct RFloat *fp;
#endif
  struct RInteger *ip;
  struct RCptr *vp;
  uintptr_t w;
  mrb_value value;
};

static inline union drb_value_
drb_val_union(mrb_value v)
{
  union drb_value_ x;
  x.value = v;
  return x;
}

#define mrb_float(o) drb_val_union(o).fp->f

static drb_api_t *drb_api;
static mrb_sym sym_draw_sprite;
static mrb_sym sym_ivar_path;

#define Data_Wrap_Struct(mrb,klass,type,ptr)\
  drb_api->mrb_data_object_alloc(mrb,klass,ptr,type)

#define Data_Make_Struct(mrb,klass,strct,type,sval,data_obj) do { \
  (data_obj) = Data_Wrap_Struct(mrb,klass,type,NULL);\
  (sval) = (strct *)drb_api->mrb_malloc(mrb, sizeof(strct));                     \
  { static const strct zero = { 0 }; *(sval) = zero; };\
  (data_obj)->data = (sval);\
} while (0)

#define Data_Get_Struct(mrb,obj,type,sval) do {\
  *(void**)&sval = drb_api->mrb_data_get_ptr(mrb, obj, type); \
} while (0)

// ===========================================================================
// ================ BEGIN IMPLEMENTATION
// ===========================================================================

float random_float() {
  return (float)rand() / (float)RAND_MAX;
}

static struct RClass *star_class;
typedef struct game_star {
  float x;
  float y;
  float s;
} game_star;

static void free_game_star(mrb_state *mrb, void *p);
static const struct mrb_data_type game_star_data_type = { "game_star", free_game_star };
static struct RClass *game_star_class;

static void free_game_star(mrb_state *mrb, void *p)
{
  game_star *star = (game_star *)p;
  free(star);
}

static mrb_value star_path_ivar_value;
static int star_path_ivar_initalized = 0;

static mrb_value game_star_new(mrb_state *mrb, mrb_value self)
{
  game_star *p;
  struct RData *d;
  Data_Make_Struct(mrb, star_class, game_star, &game_star_data_type, p, d);
  struct RBasic *star = (struct RBasic *)d;
  p->x = random_float() * -1280;
  p->y = random_float() * -720;
  p->s = 1.0 + random_float() * 4.0;
  if (!star_path_ivar_initalized) {
    star_path_ivar_value = drb_api->mrb_str_new_cstr(mrb, "sprites/misc/tiny-star.png");
    drb_api->mrb_iv_set(mrb, drb_api->mrb_obj_value(star_class), sym_ivar_path, star_path_ivar_value);
    star_path_ivar_initalized = 1;
  }
  return mrb_obj_value(star);
}

static mrb_value game_star_draw_override(mrb_state *mrb, mrb_value self)
{
  mrb_value ffi_draw = drb_api->mrb_get_arg1(mrb);

  game_star *star;
  Data_Get_Struct(mrb, self, &game_star_data_type, star);

  star->x += star->s;
  if (star->x > 1280) star->x = random_float() * -1280;

  star->y += star->s;
  if (star->y > 720) star->y = random_float() * -720;

  mrb_value x = drb_api->mrb_float_value(mrb, star->x);
  mrb_value y = drb_api->mrb_float_value(mrb, star->y);
  mrb_value w = drb_api->mrb_float_value(mrb, 4);
  mrb_value h = drb_api->mrb_float_value(mrb, 4);
  mrb_value path = star_path_ivar_value;
  drb_api->mrb_funcall_id(mrb, ffi_draw, sym_draw_sprite, 5, x, y, w, h, path);
  return drb_api->mrb_nil_value();
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *api)
{
  srand(time(NULL));
  drb_api = api;

  struct RClass *base = mrb->object_class;
  star_class = drb_api->mrb_define_class(mrb, "Star", base);
  sym_draw_sprite = drb_api->mrb_intern_lit(mrb, "draw_sprite");
  sym_ivar_path = drb_api->mrb_intern_lit(mrb, "@path");
  MRB_SET_INSTANCE_TT(star_class, MRB_TT_DATA);
  drb_api->mrb_define_class_method(mrb, star_class, "new", game_star_new, MRB_ARGS_OPT(0));
  drb_api->mrb_define_method(mrb, star_class, "draw_override", game_star_draw_override, MRB_ARGS_REQ(1));
}
