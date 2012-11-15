//
// Created by wbison on 15-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Logger.h"

@interface LogItem : NSObject
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, copy) NSString *message;

@property(nonatomic) LogLevel level;

+ (LogItem *)itemWithLevel:(LogLevel)level message:(NSString *)message;


@end