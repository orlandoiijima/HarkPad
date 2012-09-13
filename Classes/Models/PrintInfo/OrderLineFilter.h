//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface OrderLineFilter : NSObject
@property(nonatomic) bool food;
@property(nonatomic) bool drink;
@property(nonatomic) bool zeroPrice;
@property(nonatomic) bool existingLines;

+ (OrderLineFilter *)filterFromJson:(NSMutableDictionary *)filterJson;

@end