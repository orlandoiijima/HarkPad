//
//  OrderInfo.h
//  HarkPad2
//
//  Created by Willem Bison on 23-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface OrderInfo : NSObject {
}

+ (OrderInfo *) infoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property (retain) NSDate *createdOn;
@property (retain) NSMutableArray *tables;
@property (retain) NSMutableArray *seats;
@property int id;
@property OrderState state;
@property int countCourses;
@property int currentCourse;
@property (retain) NSDate *currentCourseRequestedOn;

- (BOOL) isSeatOccupied: (int) seat;

@end
