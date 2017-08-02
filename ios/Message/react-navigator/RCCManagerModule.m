#import "RCCManagerModule.h"
#import "RCCManager.h"
#import <UIKit/UIKit.h>
#import "RCCNavigationController.h"
#import "RCCViewController.h"

#import "RCCLightBox.h"
#import <React/RCTConvert.h>


#define kSlideDownAnimationDuration 0.35

typedef NS_ENUM(NSInteger, RCCManagerModuleErrorCode)
{
    RCCManagerModuleCantCreateControllerErrorCode   = -100,
    RCCManagerModuleCantFindTabControllerErrorCode  = -200,
    RCCManagerModuleMissingParamsErrorCode          = -300
};

@implementation RCTConvert (RCCManagerModuleErrorCode)

RCT_ENUM_CONVERTER(RCCManagerModuleErrorCode,
                   (@{@"RCCManagerModuleCantCreateControllerErrorCode": @(RCCManagerModuleCantCreateControllerErrorCode),
                      @"RCCManagerModuleCantFindTabControllerErrorCode": @(RCCManagerModuleCantFindTabControllerErrorCode),
                      }), RCCManagerModuleCantCreateControllerErrorCode, integerValue)
@end

@implementation RCCManagerModule

RCT_EXPORT_MODULE(RCCManager);

#pragma mark - constatnts export

- (NSDictionary *)constantsToExport
{
    return @{
             //Error codes
             @"RCCManagerModuleCantCreateControllerErrorCode" : @(RCCManagerModuleCantCreateControllerErrorCode),
             @"RCCManagerModuleCantFindTabControllerErrorCode" : @(RCCManagerModuleCantFindTabControllerErrorCode),
             };
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


#pragma mark - RCT exported methods

RCT_EXPORT_METHOD(
NavigationControllerIOS:(NSString*)controllerId performAction:(NSString*)performAction actionParams:(NSDictionary*)actionParams)
{
  if (!controllerId || !performAction) return;
  RCCNavigationController* controller = [[RCCManager sharedInstance] getControllerWithId:controllerId componentType:@"NavigationControllerIOS"];
  if (!controller || ![controller isKindOfClass:[RCCNavigationController class]]) return;
  return [controller performAction:performAction actionParams:actionParams bridge:[[RCCManager sharedInstance] getBridge]];
}

RCT_EXPORT_METHOD(
                  showController:(NSDictionary*)layout animationType:(NSString*)animationType globalProps:(NSDictionary*)globalProps resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *controller = [RCCManagerModule controllerWithLayout:layout globalProps:globalProps bridge:[[RCCManager sharedInstance] getBridge]];
    if (controller == nil)
    {
        [RCCManagerModule handleRCTPromiseRejectBlock:reject
                                                error:[RCCManagerModule rccErrorWithCode:RCCManagerModuleCantCreateControllerErrorCode description:@"could not create controller"]];
        return;
    }
    
    [[RCCManagerModule lastModalPresenterViewController] presentViewController:controller
                                                                      animated:![animationType isEqualToString:@"none"]
                                                                    completion:^(){ resolve(nil); }];
}


RCT_EXPORT_METHOD(
                  dismissController:(NSString*)animationType resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController* vc = [RCCManagerModule lastModalPresenterViewController];
    if ([self viewControllerIsModal:vc])
    {
        [[RCCManager sharedIntance] unregisterController:vc];
        
        [vc dismissViewControllerAnimated:![animationType isEqualToString:@"none"]
                               completion:^(){ resolve(nil); }];
    }
}


RCT_EXPORT_METHOD(
modalShowLightBox:(NSDictionary*)params)
{
    [RCCLightBox showWithParams:params];
}

RCT_EXPORT_METHOD(
modalDismissLightBox)
{
    [RCCLightBox dismiss];
}

+ (UIViewController*)controllerWithLayout:(NSDictionary *)layout globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge
{
    UIViewController* controller = nil;
    if (!layout) return nil;
    
    // get props
    if (!layout[@"props"]) return nil;
    if (![layout[@"props"] isKindOfClass:[NSDictionary class]]) return nil;
    NSDictionary *props = layout[@"props"];
    
    // create according to type
    NSString *type = layout[@"type"];
    if (!type) return nil;
    
    // regular view controller
    if ([type isEqualToString:@"ViewControllerIOS"])
    {
        controller = [[RCCViewController alloc] initWithProps:props globalProps:globalProps bridge:bridge];
    }
    
    // navigation controller
    if ([type isEqualToString:@"NavigationControllerIOS"])
    {
        controller = [[RCCNavigationController alloc] initWithProps:props globalProps:globalProps bridge:bridge];
    }
    
    // register the controller if we have an id
    NSString *componentId = props[@"id"];
    if (controller && componentId)
    {
        [[RCCManager sharedInstance] registerController:controller componentId:componentId componentType:type];
    }
    
    return controller;
}


+(UIViewController*)modalPresenterViewControllers:(NSMutableArray*)returnAllPresenters
{
    UIViewController *modalPresenterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ((returnAllPresenters != nil) && (modalPresenterViewController != nil))
    {
        [returnAllPresenters addObject:modalPresenterViewController];
    }
    
    while (modalPresenterViewController.presentedViewController != nil)
    {
        modalPresenterViewController = modalPresenterViewController.presentedViewController;
        
        if (returnAllPresenters != nil)
        {
            [returnAllPresenters addObject:modalPresenterViewController];
        }
    }
    return modalPresenterViewController;
}

+(UIViewController*)lastModalPresenterViewController
{
    return [self modalPresenterViewControllers:nil];
}


+(NSError*)rccErrorWithCode:(NSInteger)code description:(NSString*)description
{
    NSString *safeDescription = (description == nil) ? @"" : description;
    return [NSError errorWithDomain:@"RCCControllers" code:code userInfo:@{NSLocalizedDescriptionKey: safeDescription}];
}

+(void)handleRCTPromiseRejectBlock:(RCTPromiseRejectBlock)reject error:(NSError*)error
{
    reject([NSString stringWithFormat: @"%lu", (long)error.code], error.localizedDescription, error);
}



-(BOOL)viewControllerIsModal:(UIViewController*)viewController
{
    BOOL viewControllerIsModal = (viewController.presentingViewController.presentedViewController == viewController)
    || ((viewController.navigationController != nil) && (viewController.navigationController.presentingViewController.presentedViewController == viewController.navigationController) && (viewController == viewController.navigationController.viewControllers[0]))
    || ([viewController.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]]);
    return viewControllerIsModal;
}

@end
