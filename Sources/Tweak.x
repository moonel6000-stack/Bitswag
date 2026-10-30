#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <stdint.h>
#import <stdbool.h>
#import <string.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "dobby.h"
#import "BSMenu.h"

static NSString * const kBundle = @"com.wtfapps.apollo16";
static NSString * const kVersion = @"3.25.3";
static NSString * const kPrefs = @"com.moonel6000.bitswag";
static uintptr_t gBase;
static BOOL gHooksInstalled;


static BOOL enabled(NSString *key) {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:kPrefs];
    return [d objectForKey:key] ? [d boolForKey:key] : NO;
}
static void saveEnabled(NSString *key, BOOL value) {
    [[[NSUserDefaults alloc] initWithSuiteName:kPrefs] setBool:value forKey:key];
}
static uintptr_t findUnity(void) {
    for (uint32_t i=0; i<_dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (n && strstr(n, "/UnityFramework.framework/UnityFramework"))
            return (uintptr_t)_dyld_get_image_header(i);
    }
    return 0;
}
static BOOL supportedBuild(void) {
    NSBundle *b = [NSBundle bundleWithIdentifier:kBundle];
    NSString *v = b.infoDictionary[@"CFBundleShortVersionString"];
    return [b.bundleIdentifier isEqualToString:kBundle] && [v isEqualToString:kVersion];
}
#define TARGET(va) ((void *)(gBase + (uintptr_t)(va)))
#define HOOK(va, fn, orig) do { \
    int e = DobbyHook(TARGET(va), (void *)(fn), (void **)&(orig)); \
    if (e != 0) NSLog(@"[BitSwag] hook failed VA=0x%lx err=%d",(uintptr_t)(va),e); \
} while(0)

/* Signatures follow the supplied IL2CPP ARM64 convention: final arg is MethodInfo*. */
typedef void (*SetDoubleFn)(void *, double, void *);
typedef double (*GetDoubleFn)(void *, void *);
typedef void (*SetFloatFn)(void *, float, void *);
typedef float (*GetFloatFn)(void *, void *);
typedef void (*ImpactIntFn)(void *, int, void *);
typedef void (*ImpactIntBoolFn)(void *, int, bool, void *);
typedef bool (*BoolFloatFn)(void *, float, void *);
typedef bool (*BoolDoubleFn)(void *, double, void *);

static SetDoubleFn oBankSet, oAssetBankSet;
static GetDoubleFn oBankGet, oEffectiveBank, oVehicleValue, oEstimatedValue, oRefurbishCost;
static SetFloatFn oMoneySet, oHappySet, oVehicleConditionSet;
static GetFloatFn oMoneyGet, oHappyGet, oVehicleConditionGet;
static ImpactIntFn oHeroHappy, oPersonHappy, oVehicleImpact, oAuctionCondition, oVendorAttitude;
static ImpactIntBoolFn oStreetSmarts;
static BoolFloatFn oCanWinBid;
static BoolDoubleFn oVendorAccepts;

/* Tunable values: conservative defaults; adjust in this file if desired. */
static const double kMoney = 999999999.0;
static const float kStat = 100.0f;
static const float kCondition = 100.0f;
static const double kMarketValue = 1.0;

#define DOUBLE_SETTER(name, orig, key, forced) \
static void name(void *s,double v,void *mi){ if(enabled(@key)) v=(forced); orig(s,v,mi); }
#define FLOAT_SETTER(name, orig, key, forced) \
static void name(void *s,float v,void *mi){ if(enabled(@key)) v=(forced); orig(s,v,mi); }
#define DOUBLE_GETTER(name, orig, key, forced) \
static double name(void *s,void *mi){ return enabled(@key)?(forced):orig(s,mi); }
#define FLOAT_GETTER(name, orig, key, forced) \
static float name(void *s,void *mi){ return enabled(@key)?(forced):orig(s,mi); }

DOUBLE_SETTER(hBankSet,oBankSet,"money.bank.set",kMoney)
DOUBLE_GETTER(hBankGet,oBankGet,"money.bank.get",kMoney)
DOUBLE_GETTER(hEffectiveBank,oEffectiveBank,"money.effective",kMoney)
FLOAT_SETTER(hMoneySet,oMoneySet,"money.person.set", (float)kMoney)
FLOAT_GETTER(hMoneyGet,oMoneyGet,"money.person.get",(float)kMoney)
FLOAT_SETTER(hHappySet,oHappySet,"stats.happiness.set",kStat)
FLOAT_GETTER(hHappyGet,oHappyGet,"stats.happiness.get",kStat)
FLOAT_SETTER(hConditionSet,oVehicleConditionSet,"vehicle.condition.set",kCondition)
FLOAT_GETTER(hConditionGet,oVehicleConditionGet,"vehicle.condition.get",kCondition)
DOUBLE_GETTER(hVehicleValue,oVehicleValue,"vehicle.value",kMarketValue)
DOUBLE_GETTER(hEstimatedValue,oEstimatedValue,"market.estimated",kMarketValue)
DOUBLE_GETTER(hRefurbishCost,oRefurbishCost,"market.refurbish",0.0)

static void hAssetBankSet(void*s,double v,void*mi){if(enabled(@"money.assets.set"))v=kMoney;oAssetBankSet(s,v,mi);}
static void hHeroHappy(void*s,int v,void*mi){if(enabled(@"stats.hero.impact"))v=1000;oHeroHappy(s,v,mi);}
static void hPersonHappy(void*s,int v,void*mi){if(enabled(@"stats.person.impact"))v=1000;oPersonHappy(s,v,mi);}
static void hStreetSmarts(void*s,int v,bool b,void*mi){if(enabled(@"stats.street"))v=1000;oStreetSmarts(s,v,b,mi);}
static void hVehicleImpact(void*s,int v,void*mi){if(enabled(@"vehicle.impact"))v=1000;oVehicleImpact(s,v,mi);}
static void hAuctionCondition(void*s,int v,void*mi){if(enabled(@"vehicle.auction.impact"))v=1000;oAuctionCondition(s,v,mi);}
static void hVendorAttitude(void*s,int v,void*mi){if(enabled(@"market.vendor.attitude"))v=1000;oVendorAttitude(s,v,mi);}
static bool hCanWinBid(void*s,float v,void*mi){return enabled(@"market.winbid")?true:oCanWinBid(s,v,mi);}
static bool hVendorAccepts(void*s,double v,void*mi){return enabled(@"market.acceptbid")?true:oVendorAccepts(s,v,mi);}

static void installHooks(void) {
    if (gHooksInstalled || !supportedBuild()) return;
    gBase=findUnity(); if(!gBase) return;
    HOOK(0x3ef4340,hBankGet,oBankGet);
    HOOK(0x3ef4348,hBankSet,oBankSet);
    HOOK(0x3ef74bc,hEffectiveBank,oEffectiveBank);
    HOOK(0x4123214,hMoneyGet,oMoneyGet);
    HOOK(0x412321c,hMoneySet,oMoneySet);
    HOOK(0x4123144,hHappyGet,oHappyGet);
    HOOK(0x412314c,hHappySet,oHappySet);
    HOOK(0x3f0f8b4,hHeroHappy,oHeroHappy);
    HOOK(0x4127a2c,hPersonHappy,oPersonHappy);
    HOOK(0x40c7be0,hStreetSmarts,oStreetSmarts);
    HOOK(0x3f91570,hConditionGet,oVehicleConditionGet);
    HOOK(0x3f91578,hVehicleImpact,oVehicleImpact);
    HOOK(0x3f914c4,hConditionSet,oVehicleConditionSet);
    HOOK(0x3f21938,hAuctionCondition,oAuctionCondition);
    /* VehicleValue returns float; disabled pending ABI confirmation. */
    HOOK(0x3f23c80,hEstimatedValue,oEstimatedValue);
    HOOK(0x3f245d8,hRefurbishCost,oRefurbishCost);
    HOOK(0x3f2cd28,hVendorAttitude,oVendorAttitude);
    HOOK(0x4774eb0,hCanWinBid,oCanWinBid);
    HOOK(0x4a41fd4,hVendorAccepts,oVendorAccepts);
    /* Present in the supplied offsets list; separate bank field on asset object. */
    HOOK(0x414cfb0,hAssetBankSet,oAssetBankSet);
    gHooksInstalled=YES;
    NSLog(@"[BitSwag] hooks installed base=%p", (void *)gBase);
}


static void addMenuButton(void) {
    UIWindow *w=nil;
    for(UIScene*s in UIApplication.sharedApplication.connectedScenes)
      if(s.activationState==UISceneActivationStateForegroundActive && [s isKindOfClass:UIWindowScene.class])
        for(UIWindow*x in ((UIWindowScene*)s).windows) if(x.isKeyWindow){w=x;break;}
    if(!w || [w viewWithTag:0xB175]) return;
    UIButton *b=[UIButton buttonWithType:UIButtonTypeSystem];
    b.tag=0xB175;
    b.frame=CGRectMake(w.bounds.size.width-84, w.safeAreaInsets.top+100, 76, 42);
    b.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [b setTitle:@"BitSwag" forState:UIControlStateNormal];
    b.backgroundColor=[UIColor colorWithWhite:0 alpha:0.8];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.layer.cornerRadius=10;
    [b addTarget:[BSMenuLauncher shared] action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
    [w addSubview:b];
}
__attribute__((constructor)) static void init(void) {
    if(![NSBundle.mainBundle.bundleIdentifier isEqualToString:kBundle]) return;
    if(!supportedBuild()){NSLog(@"[BitSwag] unsupported game version; hooks disabled");return;}
    dispatch_async(dispatch_get_main_queue(), ^{
      static dispatch_source_t timer;
      timer=dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_get_main_queue());
      dispatch_source_set_timer(timer,dispatch_time(DISPATCH_TIME_NOW,0),NSEC_PER_SEC, NSEC_PER_SEC/10);
      dispatch_source_set_event_handler(timer,^{installHooks();addMenuButton();});
      dispatch_resume(timer);
    });
}
