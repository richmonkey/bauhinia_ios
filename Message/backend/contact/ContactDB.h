//
//  ContactDB.h
//  Message
//
//  Created by daozhu on 14-7-5.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABContact.h"
#import "User.h"
#import "IMContact.h"

@protocol ContactDBObserver<NSObject>
-(void)onExternalChange;
@end


@interface ContactDB : NSObject

@property(nonatomic, weak)id<ContactDBObserver> observer;

+(ContactDB*)instance;

-(NSArray *)contactsArray;

-(ABRecordRef)recordRefWithRecordID:(ABRecordID)recordID;
-(int64_t)uidFromPhoneNumber:(NSString*)phone;

-(IMUser*)loadIMUser:(int64_t)uid;
-(IMContact*)loadIMContact:(ABRecordID)recordID;

@end
