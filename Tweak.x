#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Sources/BSMenu.h"

static BOOL BSIsEnabled(void) {
    CFPropertyListRef value = CFPreferencesCopyAppValue(
        CFSTR("Enabled"), CFSTR("com.bitswag.tweak"));
    BOOL enabled = YES;
    if (value) {
        if (CFGetTypeID(value) == CFBooleanGetTypeID()) {
            enabled = CFBooleanGetValue((CFBooleanRef)value);
        }
        CFRelease(value);
    }
    return enabled;
}

%ctor {
    @autoreleasepool {
        BSLogf(@"ctor dans bundle=%@ process=%@",
               NSBundle.mainBundle.bundleIdentifier,
               NSProcessInfo.processInfo.processName);
        BOOL enabled = BSIsEnabled();
        BSLogf(@"enabled=%d", enabled);
        if (!enabled) return;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            BSLogf(@"appel de [BSMenu install]");
            [BSMenu install];
        });
    }
}
