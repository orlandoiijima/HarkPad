//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Credentials;


@interface AuthorisationToken : NSObject

@property (retain) NSString *deviceId;
@property (retain) NSString *locationId;
@property (retain) NSString *accountId;
@property (retain) NSString *pinCode;
@property (retain) NSString *email;
@property (retain) NSString *password;

+ (AuthorisationToken *) tokenFromVault;

- (void)addCredentials:(Credentials *)credentials;
- (NSString *)toHttpHeader;
- (NSMutableDictionary *)toDictionary;

@end