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


@synthesize table, seats, createdOn, state, id, countCourses, currentCourse, language, currentCourseRequestedOn;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.seats = [[NSMutableDictionary alloc] init];
        self.language = @"nl";
        self.currentCourse = -1;
	}
    return(self);
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
        order.currentCourse = [currentCourse intValue];
    
    seconds = [jsonDictionary objectForKey:@"requestedOn"];
    if(seconds != nil)
        order.currentCourseRequestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    id seatDictionary = [jsonDictionary objectForKey:@"seats"];
    for(NSString *seat in [seatDictionary allKeys])
    {
        if([seat intValue] == -1)
            continue;
        NSDictionary *seatInfoDic = [seatDictionary objectForKey:seat];
        SeatInfo *seatInfo = [SeatInfo seatInfoFromJsonDictionary:seatInfoDic];
        [order.seats setValue:seatInfo forKey:seat];
    }
    return order;
}

- (SeatInfo *) getSeatInfo: (int) querySeat
{
    for(NSString *seat in [self.seats allKeys])
    {
        if([seat intValue] == querySeat)
            return [self.seats objectForKey:seat];
    }
    return nil;
}

- (BOOL) isSeatOccupied: (int) querySeat
{
    for(NSString *seat in [self.seats allKeys])
    {
        if([seat intValue] == querySeat)
            return YES;
    }
    return NO;
}


@end

