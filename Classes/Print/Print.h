//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class OrderDocument;
@class PrinterInfo;


@interface Print : NSObject
@property(nonatomic, strong) OrderDocument *documentInfo;
@property(nonatomic, strong) PrinterInfo *printer;
@property(nonatomic, strong) id datasource;

+ (void)printWithDataSource:(id)dataSource withDocument:(OrderDocument *)documentInfo toPrinter:(PrinterInfo *)printer;

@end