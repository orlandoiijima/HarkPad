//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Session.h"
#import "User.h"
#import "Credentials.h"
#import "UserService.h"


@implementation Session {

}

static Credentials *credentials;


+ (User *) authenticatedUser {
    if (credentials ==  nil)
        return nil;
    return [[[UserService alloc]init] findUserWithPin: credentials.pincode];
}

+ (BOOL) isAuthenticatedAsAdmin {
    return credentials != nil && credentials.email != nil && credentials.password != nil;
}

+ (void) setCredentials:(Credentials *) cred {
    credentials = cred;
}

+ (Credentials *)credentials {
    return credentials;
}

@end