//
//  OrderLinePropertyValue.m
//  HarkPad
//
//  Created by Willem Bison on 09-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderLinePropertyValue.h"
#import "Cache.h"

@implementation OrderLinePropertyValue

@synthesize id, orderLineProperty, value;

+ (OrderLinePropertyValue *) valueFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    OrderLinePropertyValue *orderLinePropertyValue = [[[OrderLinePropertyValue alloc] init] autorelease];
    orderLinePropertyValue.value = [jsonDictionary objectForKey:@"value"];
    orderLinePropertyValue.id = [[jsonDictionary objectForKey:@"id"] intValue];
    int propertyId = [[jsonDictionary objectForKey:@"propertyId"] intValue];
    orderLinePropertyValue.orderLineProperty = [[[Cache getInstance] menuCard] getProductProperty:propertyId];    
    return orderLinePropertyValue;
}

- (NSString *) displayValue
{
    if(orderLineProperty.options.count > 0)
        return value;
    if([value compare:@"Y"] == NSOrderedSame)
        return orderLineProperty.name;
    return @"";
}
@end
