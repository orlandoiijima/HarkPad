//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PrintTemplate.h"
#import "DTO.h"

@class OrderLineFilter;
@class PrinterInfo;

typedef enum OrderTrigger {TriggerOrder, TriggerRequestCourse, TriggerServe, TriggerBill, TriggerPay} OrderTrigger ;

@interface PrintInfo : DTO
@property(nonatomic, strong) NSMutableArray *templates;

@property(nonatomic, strong) NSMutableArray *documents;

@property(nonatomic, strong) NSMutableArray *printers;

+ (PrintInfo *) infoFromJson:(NSMutableDictionary *)infoJson;
- (PrintTemplate *) getTemplateNamed:(NSString *)templateName;

- (NSMutableArray *)getDocumentInfoForTrigger:(OrderTrigger)trigger;


@end

@interface OrderDocument : NSObject

@property(nonatomic, strong) id name;
@property(nonatomic, strong) PrintTemplate * template;
@property(nonatomic) OrderTrigger trigger;
@property(nonatomic, strong) OrderLineFilter *filter;
@property(nonatomic, strong) PrinterInfo *printer;
@property(nonatomic) bool totalizeProducts;

+ (OrderDocument *)documentFromJson:(NSDictionary *)documentJson  printInfo: (PrintInfo *)printInfo;

@end