#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Sources/BSMenu.h"

static BOOL BSIsEnabled(void) {
    CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("Enabled"), CFSTR("com.bitswag.tweak"));
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
        if (!BSIsEnabled()) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [BSMenu install];
        });
    }
}
