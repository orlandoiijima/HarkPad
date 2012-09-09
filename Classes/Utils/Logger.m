//
// Created by wbison on 08-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Logger.h"


@implementation Logger {

}

+ (void) Info:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:args];
    [Logger Log:LogLevelInfo format:logMsg];
    va_end(args);
}

+ (void) Error:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:args];
    [Logger Log:LogLevelError format:logMsg];
    va_end(args);
}

+ (void) Log: (LogLevel)level format:(NSString *)logMsg {
    NSLog(logMsg);
}

@end