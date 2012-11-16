//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AppVault.h"
#import "KeychainWrapper.h"
#import "Credentials.h"


@implementation AppVault {

}

+ (bool) isDeviceRegistered {
    return  ([[AppVault deviceId] length] != 0);
}

+ (NSString *)deviceId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceId"];
}

+ (void)setDeviceId:(NSString *)deviceId {
    [self setOrDeleteKey:@"DeviceId" withValue:deviceId];
}

+ (NSString *)locationId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationId"];
}

+ (void)setLocationId:(NSString *)locationId {
    [self setOrDeleteKey:@"LocationId" withValue:locationId];
}

+ (NSString *)locationName {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationName"];
}

+ (void)setLocationName:(NSString *)locationName {
    [self setOrDeleteKey:@"LocationName" withValue:locationName];
}

+ (NSString *)accountId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"AccountId"];
}

+ (void)setAccountId:(NSString *)accountId {
    [self setOrDeleteKey:@"AccountId" withValue:accountId];
}


+ (void)setOrDeleteKey:(NSString *)key withValue:(NSString *)value {
    if ([value length] == 0)
        [KeychainWrapper deleteItemFromKeychainWithIdentifier: key];
    else
        [KeychainWrapper createKeychainValue:value forIdentifier: key];
}
@end