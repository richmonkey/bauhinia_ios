//
//  ContactDB.m
//  Message
//
//  Created by daozhu on 14-7-5.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactDB.h"
#import <AddressBook/AddressBook.h>
#import "ABContact.h"
#import "UserDB.h"

@interface ContactDB()
@property(nonatomic, assign)ABAddressBookRef addressBook;
@property()NSArray *contacts;
-(void)loadContacts;
@end

static void ABChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    [[ContactDB instance] loadContacts];
    [[ContactDB instance].observer onExternalChange];
}

@implementation ContactDB

+(ContactDB*)instance {
    static ContactDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[ContactDB alloc] init];
        }
    });
    return db;
}

-(id)init {
    self = [super init];
    if (self) {
        CFErrorRef err = nil;
        self.addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        if (err) {
            NSString *s = (__bridge NSString*)CFErrorCopyDescription(err);
            IMLog(@"address book error:%@", s);
            return nil;
        }
     
        __block BOOL accessGranted = NO;
        
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                IMLog(@"grant:%d", granted);
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else if (status == kABAuthorizationStatusAuthorized){
            accessGranted = YES;
        } else {
            accessGranted = NO;
        }
        if (accessGranted) {
            ABAddressBookRegisterExternalChangeCallback(self.addressBook, ABChangeCallback, nil);
            [self loadContacts];
        }
        
    }
    return self;
}

-(void)loadContacts {
    IMLog(@"load contacts");
    NSArray *thePeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
    for (id person in thePeople) {
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
    }
    
	self.contacts = array;
}

-(NSArray*)contactsArray {
    NSMutableArray *array = [NSMutableArray array];
    for (ABContact *contact in self.contacts) {
        IMSimpleContact *c = [[IMSimpleContact alloc] init];
        c.name = contact.contactName;
        c.state = @"At work";
        c.recordID = contact.recordID;
        [array addObject:c];
    }
    return array;
}

-(ABRecordRef)recordRefWithRecordID:(ABRecordID) recordID {
	ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(self.addressBook, recordID);
    return contactrec;
}

-(int64_t)uidFromPhoneNumber:(NSString*)phone {
    char tmp[64] = {0};
    char *dst = tmp;
    const char *src = [phone UTF8String];

    while (*src) {
        if (isnumber(*src)){
            *dst++ = *src;
        }
        src++;
    }
    return [[NSString stringWithUTF8String:tmp] longLongValue];
}

-(IMUser*)loadIMUser:(int64_t)uid {
    NSLog(@"is number:%d", isnumber(0x31));
    for (ABContact *contact in self.contacts) {
        for (NSDictionary *dict in contact.phoneDictionaries) {
            NSString *phone = [dict objectForKey:@"value"];
            int64_t phoneUid = [self uidFromPhoneNumber:phone];
            NSLog(@"phone:%@ uid:%lld", phone, uid);
            if (uid == phoneUid) {
                IMUser *u = [[IMUser alloc] init];
                u.contact = contact;
                u.uid = uid;
                return u;
            }
        }
    }
    return nil;
}

-(IMContact*)loadIMContact:(ABRecordID)recordID {
    IMContact *contact = [[IMContact alloc] init];
    ABRecordRef ref = [self recordRefWithRecordID:recordID];
    contact.contact = [ABContact contactWithRecord:ref];
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *dict in contact.contact.phoneDictionaries) {
        NSString *phone = [dict objectForKey:@"value"];
        int64_t phoneUid = [self uidFromPhoneNumber:phone];
        UserDB *db = [UserDB instance];
        User *u = [db loadUser:phoneUid];
        if (!u) {
            [users addObject:u];
        }
    }
    contact.users = users;
    return contact;
}

@end
