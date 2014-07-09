#import "ABContact.h"

@implementation ABContact

-(BOOL)isPerson {
    return self.recordType == kABPersonType;
}
-(id)initWithRecord: (ABRecordRef)aRecord {
    self = [super init];
    if (self) {
    }
	return self;
}

+(id)contactWithRecord:(ABRecordRef)person {
	return [[ABContact alloc] initWithRecord:person] ;
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

@end