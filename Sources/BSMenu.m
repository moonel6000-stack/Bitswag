#import "BSMenu.h"
#import <UIKit/UIKit.h>
@implementation BSMenuController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BitSwag";
}
@end
__attribute__((constructor))
static void BSMenuInitialize(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive &&
                    [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *candidate in windowScene.windows) {
                        if (candidate.isKeyWindow) {
                            window = candidate;
                            break;
                        }
                    }
                }
                if (window) {
                    break;
                }
            }
        } else {
            window = UIApplication.sharedApplication.keyWindow;
        }
        UIViewController *top = window.rootViewController;
        if (!top) {
            return;
        }
        if ([top isKindOfClass:[UINavigationController class]] &&
            [((UINavigationController *)top).topViewController
             isKindOfClass:[BSMenuController class]]) {
            return;
        }
    });
}
