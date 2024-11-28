#ifndef EXT_H
#define EXT_H
typedef struct drb_init_args {
  mrb_state *mrb;
  struct drb_api_t *drb;
} drb_init_args;
#endif
