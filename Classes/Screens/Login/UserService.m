//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UserService.h"
#import "User.h"
#import "Cache.h"
#import "Service.h"
#import "ProgressInfo.h"


@implementation UserService {

}

- (User *) findUserWithPin:(NSString *)pin {
    for (User *user in [[Cache getInstance] users]) {
        if ([user.pin isEqualToString:pin])
            return user;
    }
    return nil;
}

- (void)authenticateWithEmail:(NSString *)email
                     password:(NSString *)password
                 progressInfo: (ProgressInfo *)progressInfo
                authenticated: (void (^)(NSString *))authenticate {
    [[Service getInstance] requestResource:@"logintoken" id:nil action:nil arguments:nil body:nil verb:HttpVerbGet success:^(ServiceResult *serviceResult) {
        authenticate([serviceResult.jsonData objectForKey:@"pinCode"]);
    }                                error:^(ServiceResult *serviceResult) {
        [serviceResult displayError];
        authenticate(nil);
    }                         progressInfo:progressInfo];
}

@end