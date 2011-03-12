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

@synthesize id, quantity, product, sortOrder, guest, note, course, entityState, propertyValues, state, createdOn;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary guests: (NSArray *) guests courses: (NSArray *) courses
{
    OrderLine *orderLine = [[[OrderLine alloc] init] autorelease];
    orderLine.entityState = None;
    orderLine.id = [[jsonDictionary objectForKey:@"id"] intValue];
    int productId = [[jsonDictionary objectForKey:@"productId"] intValue];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    orderLine.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    orderLine.quantity = [[jsonDictionary objectForKey:@"quantity"] intValue];
    orderLine.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    
    if(guests != nil) {
        int seat = [[jsonDictionary objectForKey:@"seat"] intValue];
        orderLine.guest = [orderLine getGuestBySeat: seat guests:guests];
        [orderLine.guest.lines addObject:orderLine];
    }
    
    if(courses != nil) {
        int offset = [[jsonDictionary objectForKey:@"course"] intValue];
        orderLine.course = [orderLine getCourseByOffset: offset courses:courses];
        [orderLine.course.lines addObject:orderLine];
    }
    
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

- (void) setEntityState:(EntityState)newState
{
    if(self.entityState == None)
        self.entityState = newState;
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
        entityState = New;
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
    [dic setObject: [NSNumber numberWithInt:guest.seat] forKey:@"seat"];
    [dic setObject: [NSNumber numberWithInt:course.offset] forKey:@"course"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];
    if(note != nil)
        [dic setObject: note forKey:@"note"];
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