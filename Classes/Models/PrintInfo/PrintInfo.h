//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PrintTemplate.h"

@class OrderLineFilter;

typedef enum OrderTrigger {TriggerOrder, TriggerRequestCourse, TriggerServe, TriggerBill, TriggerPay} OrderTrigger ;

@interface PrintInfo : NSObject
@property(nonatomic, strong) NSMutableArray *templates;

@property(nonatomic, strong) NSMutableArray *documents;

@property(nonatomic, strong) NSMutableArray *printers;

+ (PrintInfo *) infoFromJson:(NSMutableDictionary *)infoJson;
- (PrintTemplate *) getTemplateNamed:(NSString *)templateName;

- (NSMutableArray *)getDocumentInfoForTrigger:(OrderTrigger)trigger;


@end

@interface OrderDocument : NSObject

@property(nonatomic, strong) id name;
@property(nonatomic, strong) id templateName;
@property(nonatomic) OrderTrigger trigger;
@property(nonatomic, strong) OrderLineFilter *filter;

@property(nonatomic, strong) id printer;

+ (OrderDocument *)documentFromJson:(NSDictionary *)documentJson;

@end