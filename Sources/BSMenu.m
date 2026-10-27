#import "BSMenu.h"

@implementation BSMenu
+ (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    });
}
+ (void)didBecomeActive:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive ||
                ![scene isKindOfClass:[UIWindowScene class]]) continue;
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window) break;
        }
        if (!window || [window viewWithTag:0xB175]) return;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = 0xB175;
        button.frame = CGRectMake(18, 140, 54, 54);
        button.layer.cornerRadius = 27;
        button.backgroundColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.16 alpha:0.94];
        [button setTitle:@"BS" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [button addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:button];
    });
}
+ (void)toggleMenu:(UIButton *)sender {
    UIView *existing = [sender.superview viewWithTag:0xB176];
    if (existing) { [existing removeFromSuperview]; return; }
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(82, 140, 245, 250)];
    panel.tag = 0xB176;
    panel.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.13 alpha:0.97];
    panel.layer.cornerRadius = 16;
    panel.layer.borderWidth = 1;
    panel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.16].CGColor;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 210, 28)];
    title.text = @"BitSwag";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:21];
    [panel addSubview:title];
    NSArray<NSString *> *items = @[@"Stats — planned", @"Money — planned", @"Add Cars — planned", @"Settings"];
    CGFloat y = 54;
    for (NSString *item in items) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 213, 34)];
        label.text = item;
        label.textColor = [UIColor colorWithWhite:0.92 alpha:1];
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [panel addSubview:label];
        y += 42;
    }
    [sender.superview addSubview:panel];
}
@end
