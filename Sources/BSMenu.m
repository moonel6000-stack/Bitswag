#import "BSMenu.h"
#import <UIKit/UIKit.h>
@implementation BSMenuController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BitSwag";
}
@end
%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = UIApplication.sharedApplication.keyWindow.rootViewController;
        if (!top ||
            ([top isKindOfClass:UINavigationController.class] &&
             [((UINavigationController *)top).topViewController
              isKindOfClass:BSMenuController.class])) {
            return;
        }
    });
}
