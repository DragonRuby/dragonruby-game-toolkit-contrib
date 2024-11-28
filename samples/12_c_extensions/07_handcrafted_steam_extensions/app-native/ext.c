#include <dragonruby.h>
#include "ext.h"
#include "steam_api_wrapper.h"

static drb_api_t *g_drb;

static mrb_value steam_init_api_m(mrb_state *mrb, mrb_value self)
{
  SteamAPIWrapper_Init();
  return mrb_nil_value();
}

static mrb_value steam_get_user_name_m(mrb_state *mrb, mrb_value self)
{
  const char *user_name = SteamAPIWrapper_GetCurrentUserSteamName();
  return g_drb->mrb_str_new_cstr(mrb, user_name);
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *drb) {
  printf("* INFO: C extensions registration begin.\n");
  g_drb = drb;
  struct RClass *steam = drb->mrb_define_class(mrb, "Steam", mrb->object_class);
  drb->mrb_define_method(mrb, steam, "init_api", steam_init_api_m, MRB_ARGS_NONE());
  drb->mrb_define_method(mrb, steam, "get_user_name", steam_get_user_name_m, MRB_ARGS_NONE());
  printf("* INFO: C extensions registration completed.\n");
}
