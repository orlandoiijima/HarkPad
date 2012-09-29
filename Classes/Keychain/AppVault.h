//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface AppVault : NSObject

//@property (retain) NSString *deviceId;
//@property (retain) NSString *tenantKey;

+ (NSString *)deviceKey;
+ (void)setDeviceKey:(NSString *)deviceKey;

+ (NSString *)database;
+ (void)setDatabase:(NSString *)database;

+ (int)locationId;
+ (void)setLocationId:(int)locationId;

+ (bool) isDeviceRegistered;

+ (void)setLocation:(NSString *)location;

+ (NSString *)location;


@end