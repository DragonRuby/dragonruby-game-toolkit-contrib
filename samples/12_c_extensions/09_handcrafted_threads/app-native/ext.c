// https://wiki.libsdl.org/SDL2/SDL_CreateThread
// https://wiki.libsdl.org/SDL2/SDL_WaitThread
// https://wiki.libsdl.org/SDL2/SDL_AtomicSet
// https://wiki.libsdl.org/SDL2/SDL_AtomicGet
#include <dragonruby.h>
static struct drb_api_t *drb;
static SDL_Thread *thread;
static SDL_atomic_t atomic_printing;

static int background_print(void *unused)
{
  while (drb->SDL_AtomicGet(&atomic_printing)) {
    drb->drb_log_write("Game", 2, "* INFO - Hello from the Worker class!");
    drb->SDL_Delay(1000);
  }

  return 0;
}

static mrb_value start_printing_m(mrb_state *mrb, mrb_value self)
{
  drb->drb_log_write("Game", 2, "* INFO - Starting printing invoked");
  int printing = drb->SDL_AtomicGet(&atomic_printing);

  char log_message[256] = {0};
  sprintf(log_message, "* INFO - printing: %d", printing);
  drb->drb_log_write("Game", 2, log_message);

  if (printing) return mrb_nil_value();
  thread = drb->SDL_CreateThread(background_print, "background_print", NULL);
  drb->SDL_AtomicSet(&atomic_printing, 1);

  return drb->mrb_nil_value();
}

static mrb_value printing_q_m(mrb_state *mrb, mrb_value self)
{
  int printing = drb->SDL_AtomicGet(&atomic_printing);
  return printing ? mrb_true_value() : mrb_false_value();
}

static mrb_value stop_printing_m(mrb_state *mrb, mrb_value self)
{
  drb->drb_log_write("Game", 2, "* INFO - Stopping printing invoked");
  drb->SDL_AtomicSet(&atomic_printing, 0);
  drb->SDL_WaitThread(thread, NULL);
  return drb->mrb_nil_value();
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *drb_local) {
  drb = drb_local;

  drb->drb_log_write("Game", 2, "* INFO - Registering C extension");

  drb->drb_log_write("Game", 2, "* INFO - Initializing atomic_printing to 0");
  drb->SDL_AtomicSet(&atomic_printing, 0);

  drb->drb_log_write("Game", 2, "* INFO - Registering Worker class");
  struct RClass *worker_class = drb->mrb_define_class(mrb, "Worker", mrb->object_class);
  drb->mrb_define_class_method(mrb, worker_class, "start_printing", start_printing_m, MRB_ARGS_REQ(1));
  drb->mrb_define_class_method(mrb, worker_class, "printing?", printing_q_m, MRB_ARGS_NONE());
  drb->mrb_define_class_method(mrb, worker_class, "stop_printing", stop_printing_m, MRB_ARGS_NONE());
}
