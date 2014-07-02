

#import "SDBManager.h"
#import "SUser.h"
#import "MessageModel.h"

@interface SUserDB : NSObject {
    FMDatabase * _db;
}

- (void) createDataBase;

- (void) saveUser:(SUser *) user;
- (void) deleteUserWithId:(NSString *) uid;
- (void) mergeWithUser:(SUser *) user;
- (NSArray *) findWithUid:(NSString *) uid limit:(int) limit;

- (long long) saveMessage:(MessageModel *) msg;
- (void) deleteMessageWithId:(NSInteger) msgId;
- (NSArray *) findWithSenderId:(long long) senderId limit:(int) limit;





@end
