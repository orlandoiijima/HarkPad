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
    token.deviceId = [AppVault deviceId];
    token.locationId = [AppVault locationId];
    token.accountId = [AppVault accountId];
    return token;
}

- (void)addCredentials: (Credentials *) credentials {
    self.password = credentials.password;
    self.email = credentials.email;
    self.pinCode = credentials.pinCode;
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
    if (_deviceId != nil)
        [dic setObject: _deviceId forKey:@"deviceId"];
    if (_pinCode != nil)
        [dic setObject: _pinCode forKey:@"pinCode"];
    if (_email != nil)
        [dic setObject: _email forKey:@"email"];
    if (_password != nil)
        [dic setObject: _password forKey:@"password"];
    if (_locationId != nil)
        [dic setObject: _locationId forKey:@"locationId"];
    if (_accountId != nil)
        [dic setObject: _accountId forKey:@"accountId"];
    return dic;
}

@end