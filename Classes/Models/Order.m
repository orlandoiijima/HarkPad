//
//  Order.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Order.h"

@implementation Order

@synthesize table, courses, guests, createdOn, paidOn, state, reservation, lines, name, paymentType, invoicedTo;
@dynamic firstGuest, lastCourse, lastSeat, currentCourse, nextCourseToRequest, nextCourseToServe;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.courses = [[NSMutableArray alloc] init];
        self.guests = [[NSMutableArray alloc] init];
        self.lines = [[NSMutableArray alloc] init];
        self.createdOn = [NSDate date];
        self.state = OrderStateOrdering;
        self.entityState = EntityStateNew;
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

    Order *order = [[Order alloc] initWithJson:jsonDictionary];

    order.state = (OrderState) [[jsonDictionary objectForKey:@"State"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"CreatedOn"];
    order.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    order.name = [jsonDictionary objectForKey:@"Name"];
    
    order.paymentType =(PaymentType) [[jsonDictionary objectForKey:@"PaymentType"] intValue];
    seconds = [jsonDictionary objectForKey:@"PaidOn"];
    if (seconds != nil)
        order.paidOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    id tableId = [jsonDictionary objectForKey:@"TableId"];
    if (tableId != nil)
        order.table = [cache.map getTable:[tableId intValue]];

    id guestsDic =  [jsonDictionary objectForKey:@"Guests"];
    for(NSDictionary *item in guestsDic)
    {
        Guest *guest = [Guest guestFromJsonDictionary:item order:order];
        [order.guests addObject: guest];
    }

    id coursesDic =  [jsonDictionary objectForKey:@"Courses"];
    for(NSDictionary *item in coursesDic)
    {
        Course *course = [Course courseFromJsonDictionary:item order: order];
        [order.courses addObject: course];
    }

    id lines =  [jsonDictionary objectForKey:@"Lines"];
    for(NSDictionary *item in lines)
    {
        [OrderLine orderLineFromJsonDictionary:item order: order];
    }
    
    id reservationDic = [jsonDictionary objectForKey:@"Reservation"];
    if(reservationDic != nil &&  (NSNull *)reservationDic != [NSNull null])
    {
        order.reservation = [Reservation reservationFromJsonDictionary: reservationDic];
    }

    order.entityState = EntityStateNone;
    return order;
}

+ (Order *) orderForTable: (Table *) newTable
{
    Order *order = [[Order alloc] init];
    order.table = newTable;
    for(int i = 0; i < [newTable countSeatsTotal]; i++) {
        [order addGuest];
    }
    return order;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];

    if (table != nil)
        [dic setObject: [NSNumber numberWithInt: table.id] forKey:@"TableId"];

    if (reservation != nil && reservation.id >= 0)
        [dic setObject: [NSNumber numberWithInt: reservation.id] forKey:@"ReservationId"];

    if (invoicedTo != nil)
        [dic setObject: [NSNumber numberWithInt: invoicedTo.id] forKey:@"InvoicedToId"];

    if (name != nil)
        [dic setObject:name forKey:@"Name"];

    NSMutableArray *dicCourses = nil;
    for(Course *course in [self courses])
    {
        if ([course.lines count] > 0 && course.entityState != EntityStateNone) {
            if (dicCourses == nil) {
                dicCourses = [[NSMutableArray alloc] init];
                [dic setObject:dicCourses forKey:@"Courses"];
            }
            [dicCourses addObject: [course toDictionary]];
        }
    }

    NSMutableArray *dicGuests = nil;
    for(Guest *guest in [self guests])
    {
        if (guest.entityState != EntityStateNone) {
            if (dicGuests == nil) {
                dicGuests = [[NSMutableArray alloc] init];
                [dic setObject:dicGuests forKey:@"guests"];
            }
            [dicGuests addObject: [guest toDictionary]];
        }
    }

    NSMutableArray *dicLines = nil;
    for(OrderLine *line in lines)
    {
        if (line.entityState != EntityStateNone) {
            if (dicLines == nil) {
                dicLines = [[NSMutableArray alloc] init];
                [dic setObject:dicLines forKey:@"Lines"];
            }
            [dicLines addObject: [line toDictionary]];
        }
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

- (Guest *) firstGuest
{
    if(guests.count == 0)
        return nil;
    return [guests objectAtIndex:0];
}

- (Course *)currentCourse
{
    if ([courses count] == 0) return nil;
    for(int c = courses.count - 1; c >= 0; c--)
    {
        Course *course = [courses objectAtIndex:c];
        if(course.servedOn != nil)
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
    for(Course *course in courses)
    {
        if (course.servedOn == nil)
            return course;
    }
    return nil;
}

- (OrderLine *) addLineWithProductId: (int)productId seat: (int) seat course: (int) courseOffset
{
    OrderLine *line = [[OrderLine alloc] init];

    line.order = self;
    line.entityState = EntityStateNew;
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

- (void)removeOrderLine: (OrderLine *)line {
    if([self.lines containsObject:line] == NO) {
        NSLog(@"Line not found in order");
        return;
    }
    if (line.guest != nil)
        [line.guest.lines removeObject:line];
    if (line.course != nil)
        [line.course.lines removeObject:line];
    [lines removeObject:line];
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

- (int)countCourses {
    return [courses count];
}

- (void)setCountCourses:(int)aCountCourses {}
- (void)setCurrentCourseOffset:(int)aCurrentCourseOffset {}
- (void)setCurrentCourseState:(CourseState)aCurrentCourseState {}
- (void)setCurrentCourseRequestedOn:(NSDate *)aCurrentCourseRequestedOn {}
- (void)setCurrentCourseServedOn:(NSDate *)aCurrentCourseServedOn {}
//- (void)setId:(int)anId {}
- (void)setLanguage:(NSString *)aLanguage {}

- (int)currentCourseOffset {
    Course *current = [self currentCourse];
    if(current == nil)
        return -1;
    return current.offset;
}

- (CourseState)currentCourseState {
    Course *current = [self currentCourse];
    if(current == nil)
        return -1;
    return current.state;
}

- (NSDate *)currentCourseRequestedOn {
    return nil;
}

- (NSDate *)currentCourseServedOn {
    return nil;
}

- (NSString *)language {
    if (reservation != nil)
        return reservation.language;
    return @"nl";
}



@end
