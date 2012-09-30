//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class User;
@class ProgressInfo;


@interface UserService : NSObject
- (User *)findUserWithPin:(NSString *)pin;

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password progressInfo:(ProgressInfo *)progressInfo authenticated:(void (^)(NSString *))authenticate;


@end