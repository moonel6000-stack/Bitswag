#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
void BSLogf(NSString *fmt, ...);
#ifdef __cplusplus
}
#endif

@interface BSMenu : NSObject
+ (void)install;
@end
