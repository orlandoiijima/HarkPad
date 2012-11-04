//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AuthorisationToken.h"
#import "AppVault.h"
#import "CJSONSerializer.h"
#import "NSData+Base64.h"
#import "Credentials.h"


@implementation AuthorisationToken {

}
@synthesize locationId = _locationId;


+ (AuthorisationToken *) tokenFromVault {
    AuthorisationToken *token = [[AuthorisationToken alloc] init];
    token.deviceKey = [AppVault deviceKey];
    token.pinCode = @"1234";
    token.locationId = [AppVault locationId];
    return token;
}

- (void)addCredentials: (Credentials *) credentials {
    self.password = credentials.password;
    self.email = credentials.email;
}

- (NSString *)toHttpHeader {
    NSError *error = nil;
    NSString *auth = [[CJSONSerializer serializer] serializeObject: [self toDictionary] error:&error];
    NSData *data = [auth dataUsingEncoding: NSUTF8StringEncoding];
    NSString *httpHeader = [NSString stringWithFormat:@"cellar %@", [data base64EncodedString]];
    return  httpHeader;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (_deviceKey != nil)
        [dic setObject: _deviceKey forKey:@"DeviceKey"];
    if (_pinCode != nil)
        [dic setObject: _pinCode forKey:@"UserPin"];
    if (_email != nil)
        [dic setObject: _email forKey:@"Email"];
    if (_password != nil)
        [dic setObject: _password forKey:@"Password"];
    [dic setObject: [NSNumber numberWithInt:_locationId] forKey:@"LocationId"];
    return dic;
}

@end