//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Session.h"
#import "User.h"
#import "Credentials.h"
#import "UserService.h"
#import "KitchenStatisticsDataSource.h"


@implementation Session {

}

static Credentials *credentials;
static BOOL isAuthenticatedAsAdmin;

+ (User *) authenticatedUser {
    if (credentials ==  nil)
        return nil;
    return [[[UserService alloc] init] findUserWithPin:credentials.pinCode];
}

+ (BOOL) isAuthenticatedAsAdmin {
    return isAuthenticatedAsAdmin;
}


+ (BOOL) setIsAuthenticatedAsAdmin:(BOOL)val{
    return isAuthenticatedAsAdmin = val;
}

+ (void) setCredentials:(Credentials *) cred {
    credentials = cred;
    isAuthenticatedAsAdmin = NO;
}

+ (Credentials *)credentials {
    return credentials;
}

+ (BOOL) hasFullCredentials {
    if (credentials == nil) return NO;
    if ([credentials.email length] == 0 || [credentials.password length] == 0) return NO;
    return YES;
}

@end