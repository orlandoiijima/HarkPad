//
//  OrderDetail.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderLine.h"
#import "OrderLinePropertyValue.h"
#import "Cache.h"

@implementation OrderLine

@synthesize id, quantity, product, sortOrder, seat, note, course, entityState, propertyValues, state, createdOn, requestedOn;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    OrderLine *orderLine = [[[OrderLine alloc] init] autorelease];
    orderLine.id = [[jsonDictionary objectForKey:@"id"] intValue];
    int productId = [[jsonDictionary objectForKey:@"productId"] intValue];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    orderLine.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"requestedOn"];
    if( (NSNull *) seconds != [NSNull null])
        orderLine.requestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    orderLine.quantity = [[jsonDictionary objectForKey:@"quantity"] intValue];
    orderLine.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    orderLine.seat = [[jsonDictionary objectForKey:@"seatOffset"] intValue];
    orderLine.course = [[jsonDictionary objectForKey:@"course"] intValue];
    orderLine.state = [[jsonDictionary objectForKey:@"state"] intValue];
    orderLine.note = [jsonDictionary objectForKey:@"note"];
    id propertyValues = [jsonDictionary objectForKey:@"propertyValues"];
    for(NSDictionary *propertyValueDic in propertyValues)
    {
        OrderLinePropertyValue *propertyValue = [OrderLinePropertyValue valueFromJsonDictionary: propertyValueDic]; 
        [orderLine.propertyValues addObject:propertyValue];
    }
    return orderLine;
}

- (id)init {
    if ((self = [super init])) {
        self.quantity = 1;
        propertyValues = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary *) initDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:product.id] forKey:@"productId"];
    [dic setObject: [NSNumber numberWithInt:sortOrder] forKey:@"sortOrder"];
    [dic setObject: [NSNumber numberWithInt:quantity] forKey:@"quantity"];
    [dic setObject: [NSNumber numberWithInt:seat] forKey:@"seatOffset"];
    [dic setObject: [NSNumber numberWithInt:course] forKey:@"course"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];
    return dic;
}


- (NSDecimalNumber *) getAmount
{
    NSDecimalNumber *quantityDecimal = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:quantity] decimalValue]];
    NSDecimalNumber *amount = [product.price decimalNumberByMultiplyingBy: quantityDecimal];
//    [amount retain]; 
    return amount;
}


- (OrderLinePropertyValue *) getValueForProperty: (OrderLineProperty *) property
{
    for(OrderLinePropertyValue *propertyValue in propertyValues)
    {
        if(propertyValue.orderLineProperty.id == property.id)
        {
            return propertyValue;
        }
    }
    return nil;
}

- (NSString *) getStringValueForProperty: (OrderLineProperty *) property
{
    OrderLinePropertyValue *propertyValue = [self getValueForProperty:property];
    return propertyValue == nil ? nil : propertyValue.value;
}

- (void) setStringValueForProperty : (OrderLineProperty *) property value: (NSString *) value
{
    OrderLinePropertyValue *propertyValue = [self getValueForProperty:property];
    if(propertyValue == nil)
    {
        OrderLinePropertyValue *propertyValue = [[OrderLinePropertyValue alloc] init];
        propertyValue.orderLineProperty = property;
        [propertyValues addObject:propertyValue];
    }
    propertyValue.value = value;
    
    return;
}

@end