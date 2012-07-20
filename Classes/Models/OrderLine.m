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

@synthesize order, quantity, product, sortOrder, guest, note, course, propertyValues, state, createdOn;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    OrderLine *orderLine = [[OrderLine alloc] initWithJson:jsonDictionary];
    orderLine.order = order;
    int productId = [[jsonDictionary objectForKey:@"ProductId"] intValue];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];
    NSNumber *seconds = [jsonDictionary objectForKey:@"CreatedOn"];
    orderLine.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    id val = [jsonDictionary objectForKey:@"Quantity"];
    if((NSNull *)val != [NSNull null])
        orderLine.quantity = [val intValue];
    
    val = [jsonDictionary objectForKey:@"SortOrder"];
    if((NSNull *)val != [NSNull null])
        orderLine.sortOrder = [val intValue];
    
    val = [jsonDictionary objectForKey:@"State"];
    if((NSNull *)val != [NSNull null])
        orderLine.state = (State)[val intValue];
    
    val = [jsonDictionary objectForKey:@"Note"];
    if((NSNull *)val != [NSNull null])
        orderLine.note = val;
    
    if(order != nil) {
        val = [jsonDictionary objectForKey:@"Seat"];
        if (val != nil) {
            int seat = [val intValue];
            orderLine.guest = [orderLine getGuestBySeat: seat guests: order.guests];
            [orderLine.guest.lines addObject:orderLine];
        }
    }
    
    if(order != nil) {
        val = [jsonDictionary objectForKey:@"Course"];
        if (val != nil) {
            int offset = [val intValue];
            orderLine.course = [orderLine getCourseByOffset: offset courses: order.courses];
            [orderLine.course.lines addObject:orderLine];
        }
    }
    
    if (order != nil) {
        [order.lines addObject:orderLine];
    }
    
    id propertyValues = [jsonDictionary objectForKey:@"PropertyValues"];
    for(NSDictionary *propertyValueDic in propertyValues)
    {
        OrderLinePropertyValue *propertyValue = [OrderLinePropertyValue valueFromJsonDictionary: propertyValueDic]; 
        [orderLine.propertyValues addObject:propertyValue];
    }

    orderLine.entityState = EntityStateNone;
    return orderLine;
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

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: product.key forKey:@"ProductId"];
    [dic setObject: [NSNumber numberWithInt:sortOrder] forKey:@"SortOrder"];
    [dic setObject: [NSNumber numberWithInt:quantity] forKey:@"Quantity"];
    if (guest != nil)
        [dic setObject: [NSNumber numberWithInt:guest.seat] forKey:@"Seat"];
    if (course != nil)
        [dic setObject: [NSNumber numberWithInt:course.offset] forKey:@"Course"];
    if(note != nil)
        [dic setObject: note forKey:@"Note"];

    if([propertyValues count] > 0) {
        NSMutableArray *dicProps = [[NSMutableArray alloc] init];
        [dic setObject:dicProps forKey:@"PropertyValues"];
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

    self.entityState = EntityStateModified;

    return;
}

- (void)setNote:(NSString *)aNote {
    if ([aNote isEqualToString: note] == NO) {
        self.entityState = EntityStateModified;
        note = aNote;
    }
}

- (void)setCourse:(Course *)aCourse {
    if (course == nil && aCourse == nil)
        return;
    self.entityState = EntityStateModified;
    course = aCourse;
}

- (void)setGuest:(Guest *)aGuest {
    if (guest == nil && aGuest == nil)
        return;
    self.entityState = EntityStateModified;
    guest = aGuest;
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
    line.order = self.order;
    line.quantity = self.quantity;
    line.state = self.state;
    line.createdOn = self.createdOn;
    line.entityState = self.entityState;
    line.id = self.id;
    return line;
}


@end