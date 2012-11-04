//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Credentials;


@interface AuthorisationToken : NSObject

@property (retain) NSString *deviceKey;
@property (retain) NSString *pinCode;
@property (retain) NSString *email;
@property (retain) NSString *password;

@property(nonatomic) int locationId;

+ (AuthorisationToken *) tokenFromVault;

- (void)addCredentials:(Credentials *)credentials;
- (NSString *)toHttpHeader;
- (NSMutableDictionary *)toDictionary;

@end