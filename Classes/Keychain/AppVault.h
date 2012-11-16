//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface AppVault : NSObject

//@property (retain) NSString *deviceId;
//@property (retain) NSString *tenantKey;

+ (NSString *)deviceId;
+ (void)setDeviceId:(NSString *)deviceKey;

+ (NSString *)locationId;
+ (void)setLocationId:(NSString *)locationId;

+ (NSString *)locationName;
+ (void)setLocationName:(NSString *)locationName;


+ (NSString *)accountId;
+ (void)setAccountId:(NSString *)accountId;

+ (bool) isDeviceRegistered;

@end