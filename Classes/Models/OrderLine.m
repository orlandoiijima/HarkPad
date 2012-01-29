//
//  OrderDetail.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderLine.h"
#import "OrderLinePropertyValue.h"
#import "Cache.h"
#import "Order.h"
#import "OrderGridHitInfo.h"

@implementation OrderLine

@synthesize id, quantity, product, sortOrder, guest, note, course, entityState, propertyValues, state, createdOn;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    OrderLine *orderLine = [[OrderLine alloc] init];
//    orderLine.entityState = None;
    orderLine.id = [[jsonDictionary objectForKey:@"id"] intValue];
    int productId = [[jsonDictionary objectForKey:@"productId"] intValue];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    orderLine.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    id val = [jsonDictionary objectForKey:@"quantity"];
    if((NSNull *)val != [NSNull null])
        orderLine.quantity = [val intValue];
    
    val = [jsonDictionary objectForKey:@"sortOrder"];
    if((NSNull *)val != [NSNull null])
        orderLine.sortOrder = [val intValue];
    
    val = [jsonDictionary objectForKey:@"state"];
    if((NSNull *)val != [NSNull null])
        orderLine.state = [val intValue];
    
    val = [jsonDictionary objectForKey:@"note"];
    if((NSNull *)val != [NSNull null])
        orderLine.note = val;
    
    if(order != nil) {
        int seat = [[jsonDictionary objectForKey:@"seat"] intValue];
        orderLine.guest = [orderLine getGuestBySeat: seat guests: order.guests];
        [orderLine.guest.lines addObject:orderLine];
    }
    
    if(order != nil) {
        int offset = [[jsonDictionary objectForKey:@"course"] intValue];
        orderLine.course = [orderLine getCourseByOffset: offset courses: order.courses];
        [orderLine.course.lines addObject:orderLine];
    }
    
    if (order != nil) {
        [order.lines addObject:orderLine];
    }
    
    id propertyValues = [jsonDictionary objectForKey:@"propertyValues"];
    for(NSDictionary *propertyValueDic in propertyValues)
    {
        OrderLinePropertyValue *propertyValue = [OrderLinePropertyValue valueFromJsonDictionary: propertyValueDic]; 
        [orderLine.propertyValues addObject:propertyValue];
    }
    
    return orderLine;
}

- (void) setEntityState:(EntityState)newState
{
    if(entityState == None || newState == Deleted)
        entityState = newState;
}

- (Guest *) getGuestBySeat: (int)seat guests: (NSArray *) guests
{
    for(Guest *g in guests)
    {
        if(g.seat == seat)
            return g;
    }
    return nil;
}

- (Course *) getCourseByOffset: (int)offset courses: (NSArray *) courses
{
    for(Course *c in courses)
    {
        if(c.offset == offset)
            return c;
    }
    return nil;
}


- (id)init {
    if ((self = [super init])) {
        self.quantity = 1;
        propertyValues = [[NSMutableArray alloc] init];
        self.createdOn = [NSDate date];
//        entityState = New;
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:product.id] forKey:@"productId"];
    [dic setObject: [NSNumber numberWithInt:sortOrder] forKey:@"sortOrder"];
    [dic setObject: [NSNumber numberWithInt:quantity] forKey:@"quantity"];
    [dic setObject: [NSNumber numberWithInt:guest.seat] forKey:@"seat"];
    [dic setObject: [NSNumber numberWithInt:course.offset] forKey:@"course"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];
    if(note != nil)
        [dic setObject: note forKey:@"note"];

    if([propertyValues count] > 0) {
        NSMutableArray *dicProps = [[NSMutableArray alloc] init];
        [dic setObject:dicProps forKey:@"propertyValues"];
        for(OrderLinePropertyValue *value in propertyValues)
        {
            [dicProps addObject: [value toDictionary]];
        }
    }

    return dic;
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
        propertyValue = [[OrderLinePropertyValue alloc] init];
        propertyValue.orderLineProperty = property;
        [propertyValues addObject:propertyValue];
    }
    propertyValue.value = value;
    
    return;
}

- (NSDecimalNumber *) getAmount
{
    return [self.product.price decimalNumberByMultiplyingBy: [[NSDecimalNumber alloc] initWithInt:self.quantity]];
}

- (id)copyWithZone: (NSZone *)zone {
    OrderLine *line = [[OrderLine alloc] init];
    line.product = self.product;
    line.course = self.course;
    line.guest = self.guest;
    line.quantity = self.quantity;
    line.state = self.state;
    line.createdOn = self.createdOn;
    line.entityState = self.entityState;
    line.id = self.id;
    return line;
}

@end