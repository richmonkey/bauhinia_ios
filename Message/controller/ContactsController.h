//
//  ContactsController.h
//  Phone
//
//  Created by angel li on 10-9-13.
//  Copyright 2010 Lixf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABContact.h"
#import "ContactDB.h"

@interface ContactsController : UIViewController <UITableViewDelegate, UITableViewDataSource,
                                                    ABPersonViewControllerDelegate, UISearchBarDelegate,
                                                    ContactDBObserver> {

}


@end
