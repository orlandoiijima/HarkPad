//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#include "Credentials.h"
#include "User.h"


@interface Session : NSObject

+ (User *)authenticatedUser;

+ (BOOL)isAuthenticatedAsAdmin;

+ (BOOL)setIsAuthenticatedAsAdmin:(BOOL)val;


+ (void)setCredentials:(Credentials *)cred;

+ (Credentials *)credentials;


@end