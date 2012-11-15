//
// Created by wbison on 15-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LogItem.h"
#import "Logger.h"


@implementation LogItem {

}

+ (LogItem *) itemWithLevel:(LogLevel)level message:(NSString *)message {
    LogItem *item = [[LogItem alloc] init];
    item.level = level;
    item.date = [NSDate date];
    item.message = message;
    return item;
}
@end