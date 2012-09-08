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

//+ (void) Log: (LogLevel)level format:(NSString *)format, ... ;
+ (void) Info:(NSString *)format, ...;

@end