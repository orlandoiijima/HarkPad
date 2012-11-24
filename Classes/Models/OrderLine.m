//
//  OrderDetail.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderLine.h"
#import "Cache.h"
#import "Order.h"
#import "NSDate-Utilities.h"

@implementation OrderLine

@synthesize order, quantity, product, sortOrder, guest, note, course, state, createdOn;

+ (OrderLine *) orderLineFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    OrderLine *orderLine = [[OrderLine alloc] initWithDictionary:jsonDictionary];
    orderLine.order = order;
    NSString *productId = [jsonDictionary objectForKey:@"productId"];
    orderLine.product = [[[Cache getInstance] menuCard] getProduct:productId];

    NSString *createdOn = [jsonDictionary objectForKey:@"createdOn"];
    orderLine.createdOn = [NSDate dateFromISO8601:createdOn];

    id val = [jsonDictionary objectForKey:@"quantity"];
    if((NSNull *)val != [NSNull null])
        orderLine.quantity = [val intValue];
    
    orderLine.offset = [[jsonDictionary objectForKey:@"offset"] intValue];

    val = [jsonDictionary objectForKey:@"state"];
    if((NSNull *)val != [NSNull null])
        orderLine.state = (State)[val intValue];
    
    val = [jsonDictionary objectForKey:@"note"];
    if((NSNull *)val != [NSNull null])
        orderLine.note = val;
    
    if(order != nil) {
        val = [jsonDictionary objectForKey:@"seat"];
        if (val != nil) {
            int seat = [val intValue];
            orderLine.guest = [orderLine getGuestBySeat: seat guests: order.guests];
            [orderLine.guest.lines addObject:orderLine];
        }
    }
    
    if(order != nil) {
        val = [jsonDictionary objectForKey:@"course"];
        if (val != nil) {
            int offset = [val intValue];
            orderLine.course = [orderLine getCourseByOffset: offset courses: order.courses];
            [orderLine.course.lines addObject:orderLine];
        }
    }
    
    if (order != nil) {
        [order.lines addObject:orderLine];
    }
    
    id propertyValues = [jsonDictionary objectForKey:@"properties"];
    for(NSDictionary *propertyValue in propertyValues)
    {
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
        self.propertyValues = [[NSMutableArray alloc] init];
        self.createdOn = [NSDate date];
//        entityState = New;
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: product.key forKey:@"productId"];
    [dic setObject: [NSNumber numberWithInt: _offset] forKey:@"offset"];
    [dic setObject: [NSNumber numberWithInt:quantity] forKey:@"quantity"];
    if (guest != nil)
        [dic setObject: [NSNumber numberWithInt:guest.seat] forKey:@"seat"];
    if (course != nil)
        [dic setObject: [NSNumber numberWithInt:course.offset] forKey:@"course"];
    if(note != nil)
        [dic setObject: note forKey:@"note"];

    if([_propertyValues count] > 0) {
        NSMutableArray *dicProps = [[NSMutableArray alloc] init];
        [dic setObject:dicProps forKey:@"properties"];
        for(NSString *value in _propertyValues)
        {
            [dicProps addObject: value];
        }
    }

    return dic;
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

- (NSDecimalNumber *) getVatAmount
{
    NSDecimalNumber *amount = self.getAmount;
    return [[self.product.vatPercentage decimalNumberByMultiplyingBy:amount] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
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


- (void)addProperty:(NSString *)string {
    for (NSString *property in _propertyValues) {
        if ([property caseInsensitiveCompare:string] == NSOrderedSame)
            return;
    }
    [_propertyValues addObject:string];
}

- (void)removeProperty:(NSString *)string {
    for (NSString *property in _propertyValues) {
        if ([property caseInsensitiveCompare:string] == NSOrderedSame) {
            [_propertyValues removeObject:property];
            return;
        }
    }
}

@end