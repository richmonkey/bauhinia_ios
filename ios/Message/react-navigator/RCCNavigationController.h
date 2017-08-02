#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>

@interface RCCNavigationController : UINavigationController <UINavigationControllerDelegate>

@property(nonatomic, copy) NSString *componentID;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController componentID:(NSString*)id;

- (instancetype)initWithProps:(NSDictionary *)props globalProps:(NSDictionary*)globalProps bridge:(RCTBridge *)bridge;
- (void)performAction:(NSString*)performAction actionParams:(NSDictionary*)actionParams bridge:(RCTBridge *)bridge;

@end
