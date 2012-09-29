//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class User;


@interface Session : NSObject
+ (void)setAuthenticatedUser:(User *)user;

+ (User *)authenticatedUser;

+ (void)setIsAuthenticatedAsAdmin:(BOOL)b;

+ (BOOL)isAuthenticatedAsAdmin;


@end