#include <dragonruby.h>
#import <Foundation/Foundation.h>
#import "ext.h"
#import "hello.h"

@interface HelloUtil : NSObject
- (NSString *) hello_world_with_name:(NSString *)name;
@end

@implementation HelloUtil
- (NSString *) hello_world_with_name:(NSString *)name
{
  return [NSString stringWithFormat:@"Hello %@!", name];
}
@end

static HelloUtil *hello_util;
static struct drb_api_t *drb;

static mrb_value get_message_m(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  drb->mrb_get_args(mrb, "S", &name);
  NSString *hello = [hello_util hello_world_with_name:[NSString stringWithUTF8String:RSTRING_PTR(name)]];
  return drb->mrb_str_new_cstr(mrb, [hello UTF8String]);
}

void hello_init(drb_init_args args)
{
  printf("** INFO: Creating Hello class.\n");
  drb = args.drb;
  hello_util = [[HelloUtil alloc] init];
  struct RClass *hello_class = drb->mrb_define_class(args.mrb, "Hello", args.mrb->object_class);
  drb->mrb_define_method(args.mrb, hello_class, "get_message", get_message_m, MRB_ARGS_REQ(1));
  printf("** INFO: Hello class created.\n");
}
