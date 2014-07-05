//
//  ContactDB.h
//  Message
//
//  Created by daozhu on 14-7-5.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABContact.h"

@interface ContactDB : NSObject
+(ContactDB*)instance;
- (NSArray *) contactsArray;
//Equal contacts was exist in address book
+ (NSDictionary *) hasContactsExistInAddressBookByPhone:(NSString *)phone;

//Get contact
+(ABContact *) byPhoneNumberAndLabelToGetContact:(NSString *)phone withLabel:(NSString *)label;
+(ABContact *) byPhoneNumberAndNameToGetContact:(NSString *)name withPhone:(NSString *)phone;
+(ABContact *) byNameToGetContact:(NSString *)name;
+(ABContact *) byPhoneNumberlToGetContact:(NSString *)phone withLabel:(NSString *)label;

+(NSArray *) getPhoneNumberAndPhoneLabelArray:(ABContact *) contact;
+(NSArray *) getPhoneNumberAndPhoneLabelArrayFromABRecodID:(ABRecordRef)person withABMultiValueIdentifier:(ABMultiValueIdentifier)identifierForValue;

+(NSString *) getPhoneNumberFromDic:(NSDictionary *) Phonedic;
+(NSString *) getPhoneLabelFromDic:(NSDictionary *) Phonedic;
+(NSString *) getPhoneNameFromDic:(NSDictionary *) Phonedic;

+ (BOOL)addPhone:(ABContact *)contact phone:(NSString*)phone;

+ (NSString *)getPhoneNumberFomat:(NSString *)phone;

+ (BOOL)doesStringContain:(NSString* )string Withstr:(NSString*)charcter;

+(NSString *)equalContactByAddressBookContacts:(NSString *)name withPhone:(NSString *)phone withLabel:(NSString *)label PhoneOrLabel:(BOOL)isPhone withFavorite:(BOOL)isFavorite;

+(NSString *)getContactsNameByPhoneNumberAndLabel:(NSString *)phone withLabel:(NSString *)label;

+ (BOOL) removeSelfFromAddressBook:(ABContact *)contact withErrow:(NSError **) error;

+(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT;
@end
