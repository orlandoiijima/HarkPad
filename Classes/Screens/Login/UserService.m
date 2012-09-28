//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UserService.h"
#import "User.h"
#import "Cache.h"
#import "Service.h"


@implementation UserService {

}

- (User *) findUserWithPin:(NSString *)pin {
    for (User *user in [[Cache getInstance] users]) {
        if ([user.pin isEqualToString:pin])
            return user;
    }
    return nil;
}

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password pincode:(NSString *)pin authenticated: (void (^)(BOOL isAuthenticated))authenticate {
    Credentials *credentials = [Credentials credentialsWithEmail:email password:password pincode:pin];
    [[Service getInstance] requestResource:@"logintoken" id:pin action:nil arguments:nil body:nil method:@"GET" credentials:credentials success:^(ServiceResult *serviceResult){
        authenticate(YES);
    } error:^(ServiceResult *serviceResult) {
        authenticate(NO);
    }];
}

@end