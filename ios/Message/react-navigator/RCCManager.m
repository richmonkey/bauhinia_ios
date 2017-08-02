#import "RCCManager.h"
#import <React/RCTBridge.h>
#import <React/RCTRedBox.h>
#import <Foundation/Foundation.h>

@interface RCCManager() <RCTBridgeDelegate>
@property (nonatomic, strong) NSMutableDictionary *modulesRegistry;
@property (nonatomic, strong) RCTBridge *sharedBridge;
@property (nonatomic, strong) NSURL *bundleURL;
@property (nonatomic, strong) NSMutableDictionary *components;
@end

@implementation RCCManager

+ (instancetype)sharedInstance
{
  static RCCManager *sharedInstance = nil;
  static dispatch_once_t onceToken = 0;

  dispatch_once(&onceToken,^{
    if (sharedInstance == nil)
    {
      sharedInstance = [[RCCManager alloc] init];
    }
  });

  return sharedInstance;
}

+ (instancetype)sharedIntance
{
  return [RCCManager sharedInstance];
}

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    self.modulesRegistry = [@{} mutableCopy];
    self.components = [NSMutableDictionary dictionary];
  }
  return self;
}

-(void)registerComponent:(NSString*)component class:(Class)cls {
    [self.components setObject:cls forKey:component];
}

-(Class)getComponent:(NSString*)component {
    return [self.components objectForKey:component];
}

-(void)clearModuleRegistry {
  [self.modulesRegistry removeAllObjects];
}

-(void)registerController:(UIViewController*)controller componentId:(NSString*)componentId componentType:(NSString*)componentType
{
  if (controller == nil || componentId == nil)
  {
    return;
  }

  NSMutableDictionary *componentsDic = self.modulesRegistry[componentType];
  if (componentsDic == nil)
  {
    componentsDic = [@{} mutableCopy];
    self.modulesRegistry[componentType] = componentsDic;
  }

  /*
  TODO: we really want this error, but we need to unregister controllers when they dealloc
  if (componentsDic[componentId])
  {
    [self.sharedBridge.redBox showErrorMessage:[NSString stringWithFormat:@"Controllers: controller with id %@ is already registered. Make sure all of the controller id's you use are unique.", componentId]];
  }
  */
   
  componentsDic[componentId] = controller;
}

-(void)unregisterController:(UIViewController*)vc
{
  if (vc == nil) return;
  
  for (NSString *key in [self.modulesRegistry allKeys])
  {
    NSMutableDictionary *componentsDic = self.modulesRegistry[key];
    for (NSString *componentID in [componentsDic allKeys])
    {
      UIViewController *tmpVc = componentsDic[componentID];
      if (tmpVc == vc)
      {
        [componentsDic removeObjectForKey:componentID];
      }
    }
  }
}

-(id)getControllerWithId:(NSString*)componentId componentType:(NSString*)componentType
{
  if (componentId == nil)
  {
    return nil;
  }

  id component = nil;

  NSMutableDictionary *componentsDic = self.modulesRegistry[componentType];
  if (componentsDic != nil)
  {
    component = componentsDic[componentId];
  }

  return component;
}

-(void)initBridgeWithBundleURL:(NSURL *)bundleURL
{
  [self initBridgeWithBundleURL :bundleURL launchOptions:nil];
}

-(void)initBridgeWithBundleURL:(NSURL *)bundleURL launchOptions:(NSDictionary *)launchOptions
{
  if (self.sharedBridge) return;

  self.bundleURL = bundleURL;
  self.sharedBridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
}


-(RCTBridge*)getBridge
{
  return self.sharedBridge;
}

-(UIWindow*)getAppWindow
{
  UIApplication *app = [UIApplication sharedApplication];
  UIWindow *window = (app.keyWindow != nil) ? app.keyWindow : app.windows[0];
  return window;
}

#pragma mark - RCTBridgeDelegate methods

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return self.bundleURL;
}

@end
