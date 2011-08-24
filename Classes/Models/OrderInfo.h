//
//  OrderInfo.h
//  HarkPad2
//
//  Created by Willem Bison on 23-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "SeatInfo.h"

@interface OrderInfo : NSObject {
    NSDate *createdOn;
    Table *table;
    NSMutableDictionary *seats;
    int id;
    OrderState state;
    int countCourses;
    int currentCourse;
    NSDate *currentCourseRequestedOn;
    NSDate *currentCourseServedOn;
    NSString *language;
}

+ (OrderInfo *) infoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property (retain) NSDate *createdOn;
@property (retain) Table *table;
@property (retain) NSMutableDictionary *seats;
@property int id;
@property OrderState state;
@property int countCourses;
@property int currentCourse;
@property (retain) NSDate *currentCourseRequestedOn;
@property (retain) NSDate *currentCourseServedOn;
@property (retain) NSString *language;

- (SeatInfo *) getSeatInfo: (int) querySeat;

- (BOOL) isSeatOccupied: (int) seat;

@end
