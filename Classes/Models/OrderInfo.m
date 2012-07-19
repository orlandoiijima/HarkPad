//
//  OrderInfo.m
//  HarkPad2
//
//  Created by Willem Bison on 23-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderInfo.h"
#import "Cache.h"
#import "Table.h"
#import "SeatInfo.h"

@implementation OrderInfo

@synthesize table, guests, createdOn, state, id, countCourses, currentCourseOffset, language, currentCourseRequestedOn, currentCourseServedOn;
@dynamic currentCourseState;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.guests = [[NSMutableArray alloc] init];
        self.language = @"nl";
        self.currentCourseOffset = -1;
	}
    return(self);
}

+ (OrderInfo *) infoWithOrder: (Order *)order
{
    OrderInfo *orderInfo = [[OrderInfo alloc] init];
    orderInfo.table = order.table;
    orderInfo.state = order.state;
    orderInfo.countCourses = [order.courses count];
    Course *course = [order currentCourse];
    if (course != nil) {
        orderInfo.currentCourseOffset = course.offset;
        orderInfo.currentCourseRequestedOn = course.requestedOn;
        orderInfo.currentCourseServedOn = course.servedOn;
    }
    orderInfo.guests = order.guests;
    return orderInfo;
}

+ (OrderInfo *) infoFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    OrderInfo *order = [[OrderInfo alloc] init];
    
    Cache *cache = [Cache getInstance];
    
    order.id = [[jsonDictionary objectForKey:@"Id"] intValue];
    order.state = [[jsonDictionary objectForKey:@"State"] intValue];

    int tableId = [[jsonDictionary objectForKey:@"TableId"] intValue];
    order.table = [cache.map getTable:tableId]; 
    
    id language = [jsonDictionary objectForKey:@"Language"];
    if(language != nil)
        order.language = language;
    
    NSNumber *seconds = [jsonDictionary objectForKey:@"CreatedOn"];
    order.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    order.countCourses = [[jsonDictionary objectForKey:@"CountCourses"] intValue];
    
    id currentCourse = [jsonDictionary objectForKey:@"Current"];
    if(currentCourse != nil)
        order.currentCourseOffset = [currentCourse intValue];
    
    seconds = [jsonDictionary objectForKey:@"RequestedOn"];
    if(seconds != nil)
        order.currentCourseRequestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    seconds = [jsonDictionary objectForKey:@"ServedOn"];
    if(seconds != nil)
        order.currentCourseServedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    id guestsDic =  [jsonDictionary objectForKey:@"Guests"];
    for(NSDictionary *item in guestsDic)
    {
        Guest *guest = [Guest guestFromJsonDictionary:item order: nil];
        [order.guests addObject: guest];
    }

    return order;
}

- (Guest *) getGuestBySeat: (int)seat
{
    for(Guest *guest in guests)
    {
        if(guest.seat == seat)
            return guest;
    }
    NSLog(@"No guest at seat %d", seat);
    return nil;
}

- (Guest *)addGuest {
    return nil;
}

- (CourseState) currentCourseState {
    if (currentCourseRequestedOn == nil)
        return CourseStateNothing;
    if(currentCourseServedOn == nil)
        return [currentCourseRequestedOn timeIntervalSinceNow] < -15 * 60 ? CourseStateRequestedOverdue : CourseStateRequested;
    return CourseStateServed;
}

@end

