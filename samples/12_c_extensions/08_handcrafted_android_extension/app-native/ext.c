#include <dragonruby.h>
#include <jni.h>

static drb_api_t *drb;
static jclass jclass_SDL;
static JNIEnv *jenv;
static jmethodID jmethodID_SDL_getContext;
static mrb_value get_user_defaults_m(mrb_state *mrb, mrb_value self)
{
  return drb->mrb_nil_value();
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *local_drb)
{
  drb = local_drb;
  drb->drb_log_write("Game", 2, "* INFO - Retrieving JNIEnv");
  jenv = (JNIEnv *)drb->drb_android_get_jni_env();
  drb->drb_log_write("Game", 2, "* INFO - Getting Activity class");
  jclass activity_class = (*jenv)->FindClass(jenv, "android/app/Activity");
  drb->drb_log_write("Game", 2, "* INFO - Getting getPackageName method");
  jmethodID get_package_name = (*jenv)->GetMethodID(jenv, activity_class, "getPackageName", "()Ljava/lang/String;");
  drb->drb_log_write("Game", 2, "* INFO - Getting SDL Activity");
  jobject sdl_activity = (jobject)drb->drb_android_get_sdl_activity();
  drb->drb_log_write("Game", 2, "* INFO - Getting package name");
  jstring package_name = (jstring)(*jenv)->CallObjectMethod(jenv, sdl_activity, get_package_name);
  drb->drb_log_write("Game", 2, "* INFO - Converting package name to string");
  const char *package_name_str = (*jenv)->GetStringUTFChars(jenv, package_name, NULL);
  drb->drb_log_write("Game", 2, "* INFO - Logging package name");
  drb->drb_log_write("Game", 2, package_name_str);

  drb->drb_log_write("Game", 2, "* INFO - Getting org.dragonruby.app.Bridge class.");
  jclass bridge_class = drb->drb_android_get_bridge();

  drb->drb_log_write("Game", 2, "* INFO - Getting static load method.");
  jmethodID jmethodID_load = (*jenv)->GetStaticMethodID(jenv, bridge_class, "load", "()V");
  drb->drb_log_write("Game", 2, "* INFO - Calling load method");
  (*jenv)->CallStaticVoidMethod(jenv, bridge_class, jmethodID_load);

  drb->drb_log_write("Game", 2, "* INFO - Create UserDefaults ruby class");
  struct RClass *user_defaults_class = drb->mrb_define_class(mrb, "UserDefaults", mrb->object_class);

  drb->drb_log_write("Game", 2, "* INFO - Defining get_user_defaults method");
  drb->mrb_define_method(mrb,
                         user_defaults_class,
                         "get_user_defaults",
                         get_user_defaults_m,
                         MRB_ARGS_NONE());
}
