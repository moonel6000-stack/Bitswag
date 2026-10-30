#import <UIKit/UIKit.h>

// Declarations minimales : le vrai PSListController est charge par Reglages.
@interface PSListController : UIViewController {
@protected
    NSArray *_specifiers;
}
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
@end

@interface BSSRootListController : PSListController
@end

@implementation BSSRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end
