//
// Created by wbison on 08-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Logger.h"


@implementation Logger {

}

+ (void) Info:(NSString *)logMsg {
    [Logger Log:LogLevelInfo format:logMsg];
}

+ (void) Error:(NSString *)logMsg {
    [Logger Log:LogLevelError format:logMsg];
}

+ (void) Log: (LogLevel)level format:(NSString *)logMsg {
    NSLog(logMsg);
}

@end