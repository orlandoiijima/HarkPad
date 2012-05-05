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
    
    order.id = [[jsonDictionary objectForKey:@"id"] intValue];
    order.state = [[jsonDictionary objectForKey:@"state"] intValue];

    int tableId = [[jsonDictionary objectForKey:@"tableId"] intValue];
    order.table = [cache.map getTable:tableId]; 
    
    id language = [jsonDictionary objectForKey:@"language"];
    if(language != nil)
        order.language = language;
    
    NSNumber *seconds = [jsonDictionary objectForKey:@"createdOn"];
    order.createdOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    order.countCourses = [[jsonDictionary objectForKey:@"countCourses"] intValue];
    
    id currentCourse = [jsonDictionary objectForKey:@"current"];
    if(currentCourse != nil)
        order.currentCourseOffset = [currentCourse intValue];
    
    seconds = [jsonDictionary objectForKey:@"requestedOn"];
    if(seconds != nil)
        order.currentCourseRequestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    seconds = [jsonDictionary objectForKey:@"servedOn"];
    if(seconds != nil)
        order.currentCourseServedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];

    id guestsDic =  [jsonDictionary objectForKey:@"guests"];
    for(NSDictionary *item in guestsDic)
    {
        Guest *guest = [Guest guestFromJsonDictionary:item order: nil];
        [order.guests addObject: guest];
    }

    return order;
}

- (SeatInfo *) getSeatInfo: (int) querySeat
{
//    for(NSString *seat in [self.seats allKeys])
//    {
//        if([seat intValue] == querySeat)
//            return [self.seats objectForKey:seat];
//    }
    return nil;
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

- (CourseState) currentCourseState {
    if (currentCourseRequestedOn == nil)
        return CourseStateNothing;
    if(currentCourseServedOn == nil)
        return [currentCourseRequestedOn timeIntervalSinceNow] < -15 * 60 ? CourseStateRequestedOverdue : CourseStateRequested;
    return CourseStateServed;
}

@end

