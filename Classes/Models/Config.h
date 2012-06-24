//
// Created by wbison on 24-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Config : NSObject

@property (retain) NSDictionary *settings;

+ (Config *) configFromJson: (NSDictionary *)json;
- (id) getObjectAtPath: (NSString *) path;
- (int) getIntAtPath: (NSString *) path default:(int) value;

@end