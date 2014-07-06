#import "ABContact.h"

@implementation ABContact

-(BOOL)isPerson {
    return self.recordType == kABPersonType;
}
-(id)initWithRecord: (ABRecordRef)aRecord {
    self = [super init];
    if (self) {
        record = aRecord;
        
        self.recordID = ABRecordGetRecordID(record);
        self.recordType = ABRecordGetRecordType(record);
        self.firstname = [self getRecordString:kABPersonFirstNameProperty];
        self.lastname = [self getRecordString:kABPersonLastNameProperty];
        self.middlename = [self getRecordString:kABPersonMiddleNameProperty];
        self.prefix = [self getRecordString:kABPersonPrefixProperty];
        self.suffix = [self getRecordString:kABPersonSuffixProperty];
        self.nickname = [self getRecordString:kABPersonNicknameProperty];
        
        self.emailDictionaries = [self dictionaryArrayForProperty:kABPersonEmailProperty];
        self.phoneDictionaries = [self dictionaryArrayForProperty:kABPersonPhoneProperty];
        self.relatedNameDictionaries = [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
        self.urlDictionaries =  [self dictionaryArrayForProperty:kABPersonURLProperty];
        self.dateDictionaries = [self dictionaryArrayForProperty:kABPersonDateProperty];
        self.addressDictionaries = [self dictionaryArrayForProperty:kABPersonAddressProperty];
        self.smsDictionaries = [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
        
        record = nil;
    }
	return self;
}

+(id)contactWithRecord:(ABRecordRef)person {
	return [[ABContact alloc] initWithRecord:person] ;
}


-(NSString *)getRecordString:(ABPropertyID)anID {
	return (__bridge NSString *) ABRecordCopyValue(record, anID);
}
#pragma mark Contact Name Utility
-(NSString*)contactName {
	NSMutableString *string = [NSMutableString string];
	
	if (self.firstname || self.lastname)
	{
		if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
		if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
		if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
		if (self.lastname) [string appendFormat:@"%@", self.lastname];
		
		if (self.suffix && string.length)
			[string appendFormat:@", %@ ", self.suffix];
		else
			[string appendFormat:@" "];
	}
	
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


#pragma mark Getting MultiValue Elements
- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSArray *items = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	CFRelease(theProperty);
	return items;
}


- (NSArray *) labelsForProperty:(ABPropertyID)anID {
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSMutableArray *labels = [NSMutableArray array];
	for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
	{
		NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
		[labels addObject:label];

	}
	CFRelease(theProperty);
	return labels;
}



- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
	NSArray *valueArray = [self arrayForProperty:aProperty];
	NSArray *labelArray = [self labelsForProperty:aProperty];
	
	int num = MIN(valueArray.count, labelArray.count);
	NSMutableArray *items = [NSMutableArray array];
	for (int i = 0; i < num; i++)
	{
		NSMutableDictionary *md = [NSMutableDictionary dictionary];
		[md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
		[md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
		[items addObject:md];
	}
	return items;
}
@end