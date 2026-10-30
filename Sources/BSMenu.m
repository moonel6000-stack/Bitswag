
#import "BSMenu.h"
#import <UIKit/UIKit.h>
static NSString * const domain=@"com.moonel6000.bitswag";
@interface BSMenuController : UITableViewController
@end
@implementation BSMenuLauncher
+ (instancetype)shared { static BSMenuLauncher *s; static dispatch_once_t once; dispatch_once(&once,^{s=[self new];}); return s; }
- (void)open {
    UIWindow *w=nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes)
        if ([scene isKindOfClass:UIWindowScene.class] && scene.activationState==UISceneActivationStateForegroundActive)
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows)
                if(candidate.isKeyWindow) {w=candidate;break;}
    UIViewController *top=w.rootViewController;
    while(top.presentedViewController) top=top.presentedViewController;
    if(!top || [top isKindOfClass:UINavigationController.class] && [((UINavigationController*)top).topViewController isKindOfClass:BSMenuController.class])return;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:[BSMenuController new]];
    [top presentViewController:nav animated:YES completion:nil];
}
@end
@implementation BSMenuController
- (NSArray<NSArray<NSArray<NSString*>*>*>*)groups {
 return @[
 @[@[@"Solde bancaire (lecture)",@"money.bank.get"],@[@"Solde bancaire (écriture)",@"money.bank.set"],@[@"Solde effectif",@"money.effective"],@[@"Argent personne (lecture)",@"money.person.get"],@[@"Argent personne (écriture)",@"money.person.set"],@[@"Actifs tiers (écriture)",@"money.assets.set"]],
 @[@[@"Bonheur (lecture)",@"stats.happiness.get"],@[@"Bonheur (écriture)",@"stats.happiness.set"],@[@"Impact bonheur héros",@"stats.hero.impact"],@[@"Impact bonheur personne",@"stats.person.impact"],@[@"Street smarts",@"stats.street"]],
 @[@[@"État véhicule (lecture)",@"vehicle.condition.get"],@[@"État véhicule (écriture)",@"vehicle.condition.set"],@[@"Impact état véhicule",@"vehicle.impact"],@[@"Impact état enchères",@"vehicle.auction.impact"]],
 @[@[@"Valeur estimée objet",@"market.estimated"],@[@"Coût restauration",@"market.refurbish"],@[@"Attitude vendeur",@"market.vendor.attitude"],@[@"Gagner enchère",@"market.winbid"],@[@"Vendeur accepte offre",@"market.acceptbid"]]
 ];
}
- (void)viewDidLoad {
 [super viewDidLoad];self.title=@"BitSwag 0.9.1";
 self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
 self.tableView.rowHeight=52;
}
- (void)close {[self dismissViewControllerAnimated:YES completion:nil];}
- (NSInteger)numberOfSectionsInTableView:(UITableView*)t {return self.groups.count;}
- (NSString*)tableView:(UITableView*)t titleForHeaderInSection:(NSInteger)s {return @[@"Argent",@"Statistiques",@"Véhicules",@"Marché noir"][s];}
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s {return self.groups[s].count;}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i {
 UITableViewCell *cell=[t dequeueReusableCellWithIdentifier:@"toggle"];
 if(!cell)cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"toggle"];
 NSArray *item=self.groups[i.section][i.row];
 cell.textLabel.text=item[0];cell.textLabel.font=[UIFont systemFontOfSize:14];
 UISwitch *sw=[UISwitch new];sw.accessibilityIdentifier=item[1];
 sw.on=[[[NSUserDefaults alloc]initWithSuiteName:domain]boolForKey:item[1]];
 [sw addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
 cell.accessoryView=sw;return cell;
}
- (void)change:(UISwitch*)sw {[[[NSUserDefaults alloc]initWithSuiteName:domain]setBool:sw.isOn forKey:sw.accessibilityIdentifier];}
@end
