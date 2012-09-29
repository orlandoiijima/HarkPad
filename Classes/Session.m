//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Session.h"
#import "User.h"


@implementation Session {

}

static User *authenticatedUser;
static BOOL isAuthenticatedAsAdmin;

+ (void) setAuthenticatedUser: (User *)user {
    authenticatedUser = user;
}

+ (User *) authenticatedUser {
    return authenticatedUser;
}

+ (void)setIsAuthenticatedAsAdmin:(BOOL)b {
    isAuthenticatedAsAdmin = b;
}

+ (BOOL) isAuthenticatedAsAdmin {
    return isAuthenticatedAsAdmin;
}
@end