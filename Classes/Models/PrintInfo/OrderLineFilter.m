//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderLineFilter.h"


@implementation OrderLineFilter {

}
@synthesize food = _food;
@synthesize drink = _drink;
@synthesize zeroPrice = _zeroPrice;
@synthesize existingLines = _existingLines;


+ (OrderLineFilter *) filterFromJson:(NSMutableDictionary *)filterJson
{
    OrderLineFilter *filter = [[OrderLineFilter alloc] init];
    filter.food = (bool)[[filterJson objectForKey:@"food"] intValue];
    filter.drink = (bool)[[filterJson objectForKey:@"drink"] intValue];
    filter.zeroPrice = (bool)[[filterJson objectForKey:@"zeroPrice"] intValue];
    filter.existingLines = (bool)[[filterJson objectForKey:@"existingLines"] intValue];

    return filter;
}

@end