/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>



@interface ABContact : NSObject
{
@private
	ABRecordRef record;
}

@property (nonatomic, assign) ABRecordID recordID;
@property (nonatomic, assign) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;
@property (nonatomic, copy) NSString *middlename;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *suffix;
@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, readonly) NSString *contactName;

@property (nonatomic, assign) NSArray *emailDictionaries;
@property (nonatomic, assign) NSArray *phoneDictionaries;
@property (nonatomic, assign) NSArray *relatedNameDictionaries;
@property (nonatomic, assign) NSArray *urlDictionaries;
@property (nonatomic, assign) NSArray *dateDictionaries;
@property (nonatomic, assign) NSArray *addressDictionaries;
@property (nonatomic, assign) NSArray *smsDictionaries;


+(id)contactWithRecord: (ABRecordRef) record;
-(id)initWithRecord: (ABRecordRef)aRecord;

@end