//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface AppVault : NSObject

//@property (retain) NSString *deviceKey;
//@property (retain) NSString *tenantKey;

+ (NSString *)deviceKey;
+ (void)setDeviceKey:(NSString *)deviceKey;

+ (int)locationId;
+ (void)setLocationId:(int)locationId;

+ (NSString *)locationName;
+ (void)setLocationName:(NSString *)locationName;

+ (int)accountId;
+ (void)setAccountId:(int)accountId;

+ (bool) isDeviceRegistered;

@end