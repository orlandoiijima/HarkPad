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
    return [[[UserService alloc]init] findUserWithPin: credentials.pincode];
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

@end