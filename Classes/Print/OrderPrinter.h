//
// Created by wbison on 14-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PrintInfo.h"
#import "TemplatePrintDataSource.h"

@class Order;
@class OrderDataSource;


@interface OrderPrinter : NSObject <TemplatePrintDataSource>
@property(nonatomic, strong) Order *order;
@property(nonatomic) enum OrderTrigger trigger;
@property(nonatomic, strong) OrderDataSource *orderDataSource;

@property(nonatomic, strong) OrderDocumentDefinition *orderDocument;

+ (OrderPrinter *)printerAtTrigger:(OrderTrigger)trigger order:(Order *)order;
- (void) print;

- (int)countAvailableDocumentDefinitions;

@end