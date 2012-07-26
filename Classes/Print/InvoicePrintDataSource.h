//
// Created by wbison on 26-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TemplatePrintDataSource.h"

@class OrderDataSource;
@class Order;


@interface InvoicePrintDataSource : NSObject <TemplatePrintDataSource>
@property(nonatomic, strong) OrderDataSource *orderDataSource;

+ (InvoicePrintDataSource *)dataSourceForOrder: (Order *)order;
@end