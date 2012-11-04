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
    return false;
//    return  ([[AppVault deviceKey] length] != 0);
}

+ (NSString *)deviceKey {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceKey"];
}

+ (void)setDeviceKey:(NSString *)deviceKey {
    [KeychainWrapper createKeychainValue:deviceKey forIdentifier:@"DeviceKey"];
}

+ (int)locationId {
    return [[KeychainWrapper keychainStringFromMatchingIdentifier:@"LocationId"] intValue];
}

+ (void)setLocationId:(int)locationId {
    [KeychainWrapper createKeychainValue:[NSString stringWithFormat:@"%d", locationId] forIdentifier:@"LocationId"];
}

+ (NSString *)location {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"Location"];
}

+ (void)setLocation:(NSString *)location {
    [KeychainWrapper createKeychainValue: location forIdentifier:@"Location"];
}

@end