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
    return NO;
//    return  ([[AppVault deviceKey] length] != 0);
}

+ (NSString *)deviceId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceId"];
}

+ (void)setDeviceId:(NSString *)deviceId {
    [KeychainWrapper createKeychainValue:deviceId forIdentifier:@"DeviceId"];
}

+ (NSString *)locationId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationId"];
}

+ (void)setLocationId:(NSString *)locationId {
    [KeychainWrapper createKeychainValue: locationId forIdentifier:@"LocationId"];
}

+ (NSString *)accountId {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"AccountId"];
}

+ (void)setAccountId:(NSString *)accountId {
    [KeychainWrapper createKeychainValue: accountId forIdentifier:@"AccountId"];
}

+ (NSString *)location {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"Location"];
}

+ (void)setLocation:(NSString *)location {
    [KeychainWrapper createKeychainValue: location forIdentifier:@"Location"];
}

@end