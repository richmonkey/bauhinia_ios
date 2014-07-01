

#import "SDBManager.h"
#import "SUser.h"

@interface SUserDB : NSObject {
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 */
- (void) createDataBase;
/**
 * @brief 保存一条用户记录
 * 
 * @param user 需要保存的用户数据
 */
- (void) saveUser:(SUser *) user;

/**
 * @brief 删除一条用户数据
 *
 * @param uid 需要删除的用户的id
 */
- (void) deleteUserWithId:(NSString *) uid;

/**
 * @brief 修改用户的信息
 *
 * @param user 需要修改的用户信息
 */
- (void) mergeWithUser:(SUser *) user;

/**
 * @brief 模拟分页查找数据。取uid大于某个值以后的limit个数据
 *
 * @param uid 
 * @param limit 每页取多少个
 */
- (NSArray *) findWithUid:(NSString *) uid limit:(int) limit;



/*
@property(nonatomic) int msgId;
@property(nonatomic) BOOL ack;
@property(nonatomic) int64_t sender;
@property(nonatomic) int64_t receiver;
@property(nonatomic) int type;
@property(nonatomic) NSString *raw;
@property(nonatomic) int timestamp;
*/

@end
