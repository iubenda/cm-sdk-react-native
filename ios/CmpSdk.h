
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNCmpSdkSpec.h"

@interface CmpSdk : NSObject <NativeCmpSdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface CmpSdk : NSObject <RCTBridgeModule>
#endif

@end
