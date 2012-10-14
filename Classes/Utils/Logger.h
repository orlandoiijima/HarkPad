//
// Created by wbison on 08-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Logger : NSObject

typedef enum LogLevel {
    LogLevelInfo, LogLevelWarning, LogLevelError
} LogLevel;

+ (void) Info:(NSString *)format;
+ (void) Error:(NSString *)format;

@end