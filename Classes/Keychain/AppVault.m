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
//    return NO;
    NSString *temp = [KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationId"];
    if ([temp length] > 10)
        return false;
    return  ([[AppVault deviceKey] length] != 0 && [AppVault locationId] != 0 && [AppVault accountId] != 0);
}

+ (NSString *)deviceKey {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceKey"];
}

+ (void)setDeviceKey:(NSString *)deviceKey {
    [self setOrDeleteKey:@"DeviceKey" withValue:deviceKey];
}

+ (int)locationId {
    return [[KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationId"] intValue];
}

+ (void)setLocationId:(int)locationId {
    [self setOrDeleteKey:@"LocationId" withValue:[NSString stringWithFormat:@"%d", locationId]];
}

+ (NSString *)locationName {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationName"];
}

+ (void)setLocationName:(NSString *)locationName {
    [self setOrDeleteKey:@"LocationName" withValue:locationName];
}

+ (int)accountId {
    return [[KeychainWrapper keychainStringFromMatchingIdentifier:@"AccountId"] intValue];
}

+ (void)setAccountId:(int)accountId {
    [self setOrDeleteKey:@"AccountId" withValue: [NSString stringWithFormat:@"%d", accountId]];
}


+ (void)setOrDeleteKey:(NSString *)key withValue:(NSString *)value {
    if ([value length] == 0)
        [KeychainWrapper deleteItemFromKeychainWithIdentifier: key];
    else
        [KeychainWrapper createKeychainValue:value forIdentifier: key];
}
@end