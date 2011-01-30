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
    orderLine.id = [[jsonDictionary objectForKey:@"id"] intValue];
    int productId = [[jsonDictionary objectForKey:@"productId"] intValue];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    orderLine.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    orderLine.quantity = [[jsonDictionary objectForKey:@"quantity"] intValue];
    orderLine.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    
    int guestId = [[jsonDictionary objectForKey:@"guestId"] intValue];
    orderLine.guest = [orderLine getGuestById: guestId guests:guests];
    [orderLine.guest.lines addObject:orderLine];
    
    int courseId = [[jsonDictionary objectForKey:@"courseId"] intValue];
    orderLine.course = [orderLine getCourseById: courseId courses:courses];
    [orderLine.course.lines addObject:orderLine];
    
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


- (Guest *) getGuestById: (int)guestId guests: (NSArray *) guests
{
    for(Guest *g in guests)
    {
        if(g.id == guestId)
            return g;
    }
    return nil;
}

- (Course *) getCourseById: (int)courseId courses: (NSArray *) courses
{
    for(Course *c in courses)
    {
        if(c.id == courseId)
            return c;
    }
    return nil;
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
    [dic setObject: [NSNumber numberWithInt:guest.id] forKey:@"seatOffset"];
    [dic setObject: [NSNumber numberWithInt:course.id] forKey:@"course"];
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