//
// Created by wbison on 11-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Credentials.h"


@implementation Credentials {

}
@synthesize password = _password;
@synthesize email = _email;
@synthesize pinCode = _pinCode;

+ (Credentials *)credentialsWithEmail:(NSString *)email password:(NSString *)password pinCode:(NSString *)pinCode {
    Credentials *credentials = [[Credentials alloc] init];
    credentials.email = email;
    credentials.password = password;
    credentials.pinCode = pinCode;
    return credentials;
}

@end