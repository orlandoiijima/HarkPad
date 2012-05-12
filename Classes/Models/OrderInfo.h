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
#import "OrderProxyDelegate.h"

@interface OrderInfo : NSObject <OrderProxyDelegate> {
    NSDate *createdOn;
    Table *table;
    NSMutableArray *guests;
    int id;
    OrderState state;
    int countCourses;
    int currentCourseOffset;
    NSDate *currentCourseRequestedOn;
    NSDate *currentCourseServedOn;
    NSString *language;
}

+ (OrderInfo *) infoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@property (retain) NSDate *createdOn;
@property (retain) Table *table;
@property (retain) NSMutableArray *guests;
@property int id;
@property OrderState state;
@property int countCourses;
@property int currentCourseOffset;
@property CourseState currentCourseState;
@property (retain) NSDate *currentCourseRequestedOn;
@property (retain) NSDate *currentCourseServedOn;
@property (retain) NSString *language;

- (Guest *) getGuestBySeat: (int)seat;
+ (OrderInfo *) infoWithOrder: (Order *)order;

@end
