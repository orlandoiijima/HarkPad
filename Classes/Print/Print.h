//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class OrderDocumentDefinition;
@class PrinterInfo;


@interface Print : NSObject
@property(nonatomic, strong) OrderDocumentDefinition *documentInfo;
@property(nonatomic, strong) PrinterInfo *printer;
@property(nonatomic, strong) id datasource;

+ (void)printWithDataSource:(id)dataSource withDocument:(OrderDocumentDefinition *)documentInfo toPrinter:(PrinterInfo *)printer;

@end