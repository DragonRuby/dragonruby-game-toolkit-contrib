#include <objc/objc.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ext.h"

@interface DRGTKBridge : NSObject
- (void) hello_world;
@end

@implementation DRGTKBridge {
}

- (void) hello_world {
  NSLog(@"hello from objective c!");
}

@end

DRGTKBridge *bridge;

int hello_world()
{
  bridge = [[DRGTKBridge alloc] init];
  [bridge performSelectorOnMainThread: @selector(hello_world) withObject: nil waitUntilDone: YES];
  return 1;
}
