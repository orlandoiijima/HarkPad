//
// Created by wbison on 24-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Config.h"


@implementation Config {

@private
    __strong NSDictionary *_settings;
}
@synthesize settings = _settings;


+ (Config *) configFromJson: (NSDictionary *)json
{
    Config *config = [[Config alloc] init];
    config.settings = json;
    return config;
}

- (id) getObjectAtPath: (NSString *) path {
    NSArray *parts = [path componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\\/"]];
    NSString *deviceKey = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"iphone" : @"ipad";
    id value = [_settings objectForKey:deviceKey];
    for (NSString *part in parts) {
        value = [value objectForKey:part];
    }
    return value;
}

- (int) getIntAtPath: (NSString *) path default:(int) defaultValue {
    id value = [self getObjectAtPath:path];
    if (value == nil)
        return defaultValue;
    return [value intValue];
}

@end