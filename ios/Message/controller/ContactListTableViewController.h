//
//  ContactListTableViewController.h
//  Phone
//
//  Created by angel li on 10-9-13.
//
//

#import <UIKit/UIKit.h>
#import "ABContact.h"
#import "ContactDB.h"

@class RCTBridge;

@interface ContactListTableViewController : UIViewController <UITableViewDelegate,
                                                            UITableViewDataSource,
                                                            ContactDBObserver> {

}

- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;
@end
