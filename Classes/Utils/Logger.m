//
// Created by wbison on 08-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Logger.h"
#import "LogItem.h"
#import "TestFlight.h"


@implementation Logger {

}

static NSMutableArray *lines;

+ (void)info:(NSString *)logMsg {
    [Logger log:LogLevelInfo format:logMsg];
}

+ (void)error:(NSString *)logMsg {
    [Logger log:LogLevelError format:logMsg];
}

+ (void)log:(LogLevel)level format:(NSString *)logMsg {
    NSLog(@"%@", logMsg);
    TFLog([logMsg length] > 256 ? [logMsg substringToIndex:256]: logMsg);
    if (lines == nil)
        lines = [[NSMutableArray alloc] init];
    LogItem *item = [LogItem itemWithLevel:(LogLevel)level message:logMsg];
    [lines addObject: item];
}

+ (NSMutableArray *) lines {
    return lines;
}
@end