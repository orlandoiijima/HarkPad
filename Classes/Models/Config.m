//
// Created by wbison on 24-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Config.h"


@implementation Config

@synthesize settings = _settings;


+ (Config *) configFromJson: (NSDictionary *)json
{
    Config *config = [[Config alloc] init];
    config.settings = json;
    return config;
}

- (id)getDeviceObjectAtPath: (NSString *) path {
    NSString *devicePath = [NSString stringWithFormat:@"%@/%@", (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"IPhone" : @"IPad", path];
    return [self getObjectAtPath:devicePath];
}

- (id)getObjectAtPath: (NSString *) path {
    NSArray *parts = [path componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\\/"]];
    id value = _settings;
    for (NSString *part in parts) {
        value = [value objectForKey:part];
    }
    return value;
}

- (int)getIntAtPath:(NSString *)path default:(int) defaultValue {
    id value = [self getObjectAtPath:path];
    if (value == nil)
        return defaultValue;
    return [value intValue];
}

- (BOOL)getBoolAtPath:(NSString *)path default:(BOOL) defaultValue {
    id value = [self getObjectAtPath:path];
    if (value == nil)
        return defaultValue;
    return (BOOL)[value intValue];
}

@end