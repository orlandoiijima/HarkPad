//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum PrinterType {PrinterTypeStar, PrinterTypeAirplay} PrinterType ;

@interface PrinterInfo : NSObject
@property(nonatomic, strong) id name;
@property(nonatomic, strong) id address;
@property(nonatomic) PrinterType type;

+ (PrinterInfo *)printerFromJson:(NSDictionary *)dictionary;

@end