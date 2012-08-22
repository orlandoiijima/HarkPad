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
@synthesize pincode = _pincode;

+ (Credentials *) credentialsWithEmail:(NSString *)email password:(NSString *)password pincode:(NSString *)pincode {
    Credentials *credentials = [[Credentials alloc] init];
    credentials.email = email;
    credentials.password = password;
    credentials.pincode = pincode;
    return credentials;
}

@end