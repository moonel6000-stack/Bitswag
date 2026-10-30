#import "BSMenu.h"
#import "BSDump.h"

void BSLogf(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    NSLog(@"[BitSwag] %@", msg);
    @synchronized ([NSProcessInfo processInfo]) {
        NSString *path = [NSTemporaryDirectory()
            stringByAppendingPathComponent:@"bitswag.log"];
        NSData *line = [[NSString stringWithFormat:@"%@ %@\n",
            [NSDate date], msg] dataUsingEncoding:NSUTF8StringEncoding];
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
        if (!fh) {
            [line writeToFile:path atomically:YES];
        } else {
            [fh seekToEndOfFile];
            [fh writeData:line];
            [fh closeFile];
        }
    }
}

@interface BSPassthroughWindow : UIWindow
@end

@implementation BSPassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self || hit == self.rootViewController.view) return nil;
    return hit;
}
@end

static BSPassthroughWindow *gWindow;
static int gAttempts;

@implementation BSMenu

+ (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BSLogf(@"install, etat app=%ld",
               (long)UIApplication.sharedApplication.applicationState);
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(tryShow)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
        [self tryShow];
    });
}

+ (void)retryLater {
    if (gWindow || gAttempts >= 20) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        [self tryShow];
    });
}

+ (void)tryShow {
    if (gWindow) return;
    gAttempts++;
    UIApplication *app = UIApplication.sharedApplication;
    BSLogf(@"tentative %d, scenes=%lu, etat=%ld", gAttempts,
           (unsigned long)app.connectedScenes.count,
           (long)app.applicationState);

    if (app.applicationState != UIApplicationStateActive) {
        BSLogf(@"app pas encore active, nouvel essai plus tard");
        [self retryLater];
        return;
    }

    UIWindowScene *scene = nil;
    for (UIScene *s in app.connectedScenes) {
        if (![s isKindOfClass:[UIWindowScene class]]) continue;
        if (!scene ||
            s.activationState == UISceneActivationStateForegroundActive) {
            scene = (UIWindowScene *)s;
        }
    }

    BSPassthroughWindow *w;
    if (scene) {
        w = [[BSPassthroughWindow alloc] initWithWindowScene:scene];
        BSLogf(@"fenetre liee a une scene");
    } else {
        w = [[BSPassthroughWindow alloc]
             initWithFrame:UIScreen.mainScreen.bounds];
        BSLogf(@"aucune scene -> fenetre sans scene");
    }
    w.windowLevel = UIWindowLevelAlert + 100;
    w.backgroundColor = UIColor.clearColor;
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.clearColor;
    w.rootViewController = vc;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(18, 140, 54, 54);
    button.layer.cornerRadius = 27;
    button.backgroundColor =
        [UIColor colorWithRed:0.13 green:0.13 blue:0.16 alpha:0.94];
    [button setTitle:@"BS" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [button addTarget:self action:@selector(toggleMenu:)
     forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:button];

    w.hidden = NO;
    gWindow = w;
    BSLogf(@"fenetre creee, bouton ajoute, frame=%@",
           NSStringFromCGRect(w.frame));
}

+ (void)toggleMenu:(UIButton *)sender {
    UIView *host = sender.superview;
    UIView *existing = [host viewWithTag:0xB176];
    if (existing) { [existing removeFromSuperview]; return; }
    BSLogf(@"ouverture du panneau");

    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(82, 140, 245, 250)];
    panel.tag = 0xB176;
    panel.backgroundColor =
        [UIColor colorWithRed:0.10 green:0.10 blue:0.13 alpha:0.97];
    panel.layer.cornerRadius = 16;
    panel.layer.borderWidth = 1;
    panel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.16].CGColor;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 210, 28)];
    title.text = @"BitSwag";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:21];
    [panel addSubview:title];

    NSArray<NSString *> *items = @[@"Stats — planned", @"Money — planned",
                                   @"Add Cars — planned"];
    CGFloat y = 54;
    for (NSString *item in items) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 213, 34)];
        l.text = item;
        l.textColor = [UIColor colorWithWhite:0.92 alpha:1];
        l.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [panel addSubview:l];
        y += 42;
    }
    UIButton *dump = [UIButton buttonWithType:UIButtonTypeSystem];
    dump.frame = CGRectMake(16, y, 213, 34);
    dump.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [dump setTitle:@"Dump IL2CPP (diagnostic)" forState:UIControlStateNormal];
    [dump addTarget:self action:@selector(dumpTapped:)
   forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:dump];
    [host addSubview:panel];
}

+ (void)dumpTapped:(UIButton *)sender {
    BSLogf(@"dump demande");
    NSString *path = BSDumpIL2CPP();
    if (!path) {
        [sender setTitle:@"Dump echoue (voir bitswag.log)"
                forState:UIControlStateNormal];
        return;
    }
    [sender setTitle:@"Dump OK" forState:UIControlStateNormal];
    UIActivityViewController *vc = [[UIActivityViewController alloc]
        initWithActivityItems:@[[NSURL fileURLWithPath:path]]
        applicationActivities:nil];
    UIViewController *root = gWindow.rootViewController;
    vc.popoverPresentationController.sourceView = sender;
    [root presentViewController:vc animated:YES completion:nil];
}

@end
