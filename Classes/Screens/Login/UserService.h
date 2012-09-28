//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class User;


@interface UserService : NSObject
- (User *)findUserWithPin:(NSString *)pin;

- (BOOL)authenticateWithEmail:(NSString *)email password:(NSString *)password pincode:(NSString *)pin authenticated:(void (^)(BOOL))authenticate;


@end