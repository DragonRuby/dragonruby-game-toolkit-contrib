#include <objc/objc.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ext.h"

@interface DRDRBridge : NSObject
- (void) hello_world;
@end

@implementation DRDRBridge {
}

- (void) hello_world {
  NSLog(@"hello from objective c!");
}

@end

DRDRBridge *bridge;

int hello_world()
{
  bridge = [[DRDRBridge alloc] init];
  [bridge performSelectorOnMainThread: @selector(hello_world) withObject: nil waitUntilDone: YES];
  return 1;
}
