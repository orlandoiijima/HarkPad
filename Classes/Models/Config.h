//
// Created by wbison on 24-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Config : NSObject {
    NSDictionary *_settings;
}

@property (retain) NSDictionary *settings;

+ (Config *) configFromJson: (NSDictionary *)json;
- (id)getDeviceObjectAtPath: (NSString *) path;

- (BOOL)getBoolAtPath:(NSString *)path default:(BOOL)defaultValue;

- (int)getIntAtPath:(NSString *)path default:(int)defaultValue;

@end