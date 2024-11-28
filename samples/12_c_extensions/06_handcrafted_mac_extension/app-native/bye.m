#include <dragonruby.h>
#import <Foundation/Foundation.h>
#import "ext.h"
#import "bye.h"

@interface ByeUtil : NSObject
- (NSString *) bye_world_with_name:(NSString *)name;
@end

@implementation ByeUtil
- (NSString *) bye_world_with_name:(NSString *)name
{
  return [NSString stringWithFormat:@"Bye %@!", name];
}
@end

static ByeUtil *bye_util;
static struct drb_api_t *drb;

static mrb_value get_message_m(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  drb->mrb_get_args(mrb, "S", &name);
  NSString *bye = [bye_util bye_world_with_name:[NSString stringWithUTF8String:RSTRING_PTR(name)]];
  return drb->mrb_str_new_cstr(mrb, [bye UTF8String]);
}

void bye_init(drb_init_args args)
{
  printf("** INFO: Creating Bye class.\n");
  drb = args.drb;
  bye_util = [[ByeUtil alloc] init];
  struct RClass *bye_class = drb->mrb_define_class(args.mrb, "Bye", args.mrb->object_class);
  drb->mrb_define_method(args.mrb, bye_class, "get_message", get_message_m, MRB_ARGS_REQ(1));
  printf("** INFO: Bye class created.\n");
}
