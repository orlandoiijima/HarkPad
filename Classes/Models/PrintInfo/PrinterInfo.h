//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

typedef enum PrinterType {PrinterTypeStar, PrinterTypeAirplay} PrinterType ;

@interface PrinterInfo : DTO
@property(nonatomic, strong) NSString * name;
@property(nonatomic, strong) NSString * address;
@property(nonatomic) PrinterType type;
@property(nonatomic) BOOL isOnline;

+ (PrinterInfo *)printerFromJson:(NSDictionary *)dictionary;

@end