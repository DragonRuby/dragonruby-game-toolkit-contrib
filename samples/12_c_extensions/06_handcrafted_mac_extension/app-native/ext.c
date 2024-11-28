#include <dragonruby.h>
#include "ext.h"
#include "hello.h"
#include "bye.h"

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *drb) {
  printf("* INFO: C extensions registration begin.\n");
  drb_init_args args = { .mrb = mrb, .drb = drb };
  hello_init(args);
  bye_init(args);
  printf("* INFO: C extensions registration completed.\n");
}
