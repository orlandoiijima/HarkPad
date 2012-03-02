//
//  Order.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "Guest.h"
#import "Course.h"
#import "OrderLine.h"
#import "OrderGridHitInfo.h"

@implementation Order

@synthesize table, courses, guests, createdOn, paidOn, state, entityState, reservation, id, lines, name, paymentType, invoicedTo;
@dynamic lastCourse, lastSeat, currentCourse, nextCourseToRequest, nextCourseToServe;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.courses = [[NSMutableArray alloc] init];
        self.guests = [[NSMutableArray alloc] init];
        self.lines = [[NSMutableArray alloc] init];
        self.createdOn = [NSDate date];
        self.state = OrderStateOrdering;
        self.entityState = New;
	}
    return(self);
}

+ (Order *) orderNull
{
    Order *order = [[Order alloc] init];
    order.id = -1;
    return order;
}

- (BOOL) isNullOrder
{
    return id == -1;
}

+ (Order *) orderFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Cache *cache = [Cache getInstance];

    Order *order = [[Order alloc] init];
    order.id = [[jsonDictionary objectForKey:@"id"] intValue];
    order.entityState = None;
    order.state = (OrderState) [[jsonDictionary objectForKey:@"state"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    order.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    order.name = [jsonDictionary objectForKey:@"name"];
    
    order.paymentType =(PaymentType) [[jsonDictionary objectForKey:@"paymentType"] intValue];
    seconds = [jsonDictionary objectForKey:@"paidOn"];
    if (seconds != nil)
        order.paidOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    id tableId = [jsonDictionary objectForKey:@"tableId"];
    if (tableId != nil)
        order.table = [cache.map getTable:[tableId intValue]];

    id guestsDic =  [jsonDictionary objectForKey:@"guests"];
    for(NSDictionary *item in guestsDic)
    {
        Guest *guest = [Guest guestFromJsonDictionary:item order:order];
        [order.guests addObject: guest];
    }

    id coursesDic =  [jsonDictionary objectForKey:@"courses"];
    for(NSDictionary *item in coursesDic)
    {
        Course *course = [Course courseFromJsonDictionary:item order: order];
        [order.courses addObject: course];
    }

    id lines =  [jsonDictionary objectForKey:@"lines"];
    for(NSDictionary *item in lines)
    {
        [OrderLine orderLineFromJsonDictionary:item order: order];
    }
    
    id reservationDic = [jsonDictionary objectForKey:@"reservation"];
    if(reservationDic != nil &&  (NSNull *)reservationDic != [NSNull null])
    {
        order.reservation = [Reservation reservationFromJsonDictionary: reservationDic];
    }
    return order;
}

+ (Order *) orderForTable: (Table *) newTable
{
    Order *order = [[Order alloc] init];
    order.table = newTable;
    for(int i = 0; i < 2 * (newTable.seatsHorizontal + newTable.seatsVertical); i++) {
        [order addGuest];
    }
    return order;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt: [self id]] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt: [self entityState]] forKey:@"entityState"];

    if (table != nil)
        [dic setObject: [NSNumber numberWithInt: table.id] forKey:@"tableId"];

    if (reservation != nil && reservation.id >= 0)
        [dic setObject: [NSNumber numberWithInt: reservation.id] forKey:@"reservationId"];

    if (invoicedTo != nil)
        [dic setObject: [NSNumber numberWithInt: invoicedTo.id] forKey:@"invoicedToId"];

    if (name != nil)
        [dic setObject:name forKey:@"name"];

    if ([courses count] > 0) {
        NSMutableArray *dicCourses = [[NSMutableArray alloc] init];
        [dic setObject:dicCourses forKey:@"courses"];
        for(Course *course in [self courses])
        {
            if ([course.lines count] > 0)
                [dicCourses addObject: [course toDictionary]];
        }
    }

    if ([guests count] > 0) {
        NSMutableArray *dicGuests = [[NSMutableArray alloc] init];
        [dic setObject:dicGuests forKey:@"guests"];
        for(Guest *guest in [self guests])
        {
            [dicGuests addObject: [guest toDictionary]];
        }
    }

    NSMutableArray *dicLines = [[NSMutableArray alloc] init];
    [dic setObject:dicLines forKey:@"lines"];
    for(OrderLine *line in lines)
    {
        [dicLines addObject: [line toDictionary]];
    }
    return dic;
}

- (Guest *) getGuestBySeat: (int)seat
{
    for(Guest *guest in guests)
    {
        if(guest.seat == seat)
            return guest;
    }
    return nil;
}

- (Course *) getCourseByOffset: (int)offset
{
    for(Course *course in courses)
    {
        if(course.offset == offset)
            return course;
    }
    return nil;
}

- (BOOL) isCourseAlreadyRequested: (int) courseOffset
{
    Course *course = [self getCourseByOffset:courseOffset];
    if(course == nil) return false;
    if(course.requestedOn == nil) return false;
    return true;
}

- (NSDecimalNumber *)totalAmount
{
    id total = [NSDecimalNumber zero];
    for(OrderLine *line in lines)
    {
        NSDecimalNumber *lineTotal = [line.product.price decimalNumberByMultiplyingBy: [[NSDecimalNumber alloc] initWithInt:line.quantity]];
        total = [total decimalNumberByAdding: lineTotal];
    }
    return total;
}

- (Course *)lastCourse
{
    if(courses.count == 0)
        return nil;
    return [courses objectAtIndex:courses.count-1];
}

- (int) lastSeat
{
    if(guests.count == 0)
        return -1;
    Guest *guest = [guests objectAtIndex:guests.count-1];
    return guest.seat;
}

- (Course *)currentCourse
{
    if ([courses count] == 0) return nil;
    for(int c = courses.count - 1; c >= 0; c--)
    {
        Course *course = [courses objectAtIndex:c];
        if(course.requestedOn != nil)
            return course;
    
    }
    return nil;
}

- (Course *)nextCourseToRequest
{
    for(Course *course in courses)
    {
        if(course.requestedOn == nil)
            return course;
    }
    return nil;
}

- (Course *)nextCourseToServe
{
    for(int c = courses.count - 1; c >= 0; c--)
    {
        Course *course = [courses objectAtIndex:c];
        if (course.servedOn != nil)
            return nil;
        if(course.requestedOn != nil)
            return course;
    
    }
    return nil;
}

- (OrderLine *) addLineWithProductId: (int)productId seat: (int) seat course: (int) courseOffset
{
    OrderLine *line = [[OrderLine alloc] init];

    line.order = self;
    line.entityState = New;
    line.quantity = 1;

    if (productId >= 0)
        line.product = [[[Cache getInstance] menuCard] getProduct:productId];

    line.sortOrder = 0;
    if (courseOffset >= 0) {
        line.course = [self getCourseByOffset:courseOffset];
        if(line.course == nil)
        {
            line.course = [[Course alloc] init];
            line.course.offset = courseOffset;
            [self.courses addObject:line.course];
        }
    }

    if (seat >= 0) {
        line.guest = [self getGuestBySeat:seat];
        if(line.guest == nil)
        {
            line.guest = [[Guest alloc] init];
            line.guest.seat = seat;
            [self.guests addObject:line.guest];
        }
    }

    [self addOrderLine:line];
    return line;
}

- (void)addOrderLine: (OrderLine *)line {
    [self.lines addObject:line];
    line.order = self;
    if(line.course != nil)
        [line.course.lines addObject:line];
    if (line.guest != nil)
        [line.guest.lines addObject:line];
    return;
}

- (Course *) addCourse
{
    Course *course = [[Course alloc] init];
    course.offset = [self.courses count];
    course.order = self;
    [self.courses addObject:course];
    return course;
}

- (Guest *) addGuest
{
    Guest *guest = [[Guest alloc] init];
    guest.seat = [self.guests count];
    guest.order = self;
    [self.guests addObject:guest];
    return guest;

}

@end
