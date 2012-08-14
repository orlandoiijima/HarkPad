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

+ (Credentials *) credentialsWithEmail:(NSString *)email password:(NSString *)password {
    Credentials *credentials = [[Credentials alloc] init];
    credentials.email = email;
    credentials.password = password;
    return credentials;
}
@end