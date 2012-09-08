//
// Created by wbison on 10-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AppVault.h"
#import "KeychainWrapper.h"


@implementation AppVault {

}

+ (bool) isDeviceRegistered {
    return  ([[AppVault database] length] != 0 && [[AppVault deviceKey] length] != 0);
}

+ (NSString *)deviceKey {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceKey"];
}

+ (void)setDeviceKey:(NSString *)deviceKey {
    [KeychainWrapper createKeychainValue:deviceKey forIdentifier:@"DeviceKey"];
}

+ (NSString *)database {
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"Database"];
}

+ (void)setDatabase:(NSString *)database {
    [KeychainWrapper createKeychainValue:database forIdentifier:@"Database"];
}
@end