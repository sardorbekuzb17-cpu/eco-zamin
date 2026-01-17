#import "MyIdPlugin.h"
#if __has_include(<myid/myid-Swift.h>)
#import <myid/myid-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "myid-Swift.h"
#endif

@implementation MyIdPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMyIdPlugin registerWithRegistrar:registrar];
}
@end

