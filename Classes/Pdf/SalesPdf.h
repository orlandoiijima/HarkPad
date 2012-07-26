//
// Created by wbison on 22-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TemplatePrintDataSource.h"


@interface SalesPdf : NSObject <TemplatePrintDataSource>

@property(nonatomic, strong) NSDate *from;
@property(nonatomic, strong) NSDate *to;
@end