//
//  Order.h
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderLine.h"
#import "Cache.h"
#import "Reservation.h"

typedef enum OrderGrouping {noGrouping, bySeat, byCourse, byCategory} OrderGrouping ;
typedef enum OrderState {ordering, billed, paid} OrderState ;

@interface Order : NSObject {
    EntityState entityState;
    NSMutableArray *courses;
    NSMutableArray *guests;
    NSMutableArray *lines;
    Reservation *reservation;
    NSDate *createdOn;
    NSString *name;
    Table *table;
    int id;
    OrderState state;
}


+ (Order *) orderForTable: (Table *) table;
+ (Order *) orderFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toDictionary;
- (NSDecimalNumber *) getAmount;
- (BOOL) containsProductId:(int)id;
- (OrderLine *) addLineWithProductId: (int) productId seat: (int) seat course: (int) course;
- (int) getLastCourse;
- (int) getLastSeat;
- (NSDate *) getFirstOrderDate;
- (NSDate *) getLastOrderDate;
- (Course *) getCurrentCourse;
- (Course *) getNextCourse;

- (Guest *) getGuestById: (int)guestId;
- (Course *) getCourseById: (int)courseId;
- (Course *) getCourseByOffset: (int)offset;
- (Guest *) getGuestBySeat: (int)seat;
- (BOOL) isCourseAlreadyRequested: (int) courseOffset;
- (void) removeOrderLine: (OrderLine *)lineToDelete;
- (void)addOrderLine: (OrderLine *)line;

@property EntityState entityState;
@property (retain) NSMutableArray *courses;
@property (retain) NSMutableArray *guests;
@property (retain) NSMutableArray *lines;
@property (retain) NSDate *createdOn;
@property (retain) Table *table;
@property (retain) Reservation *reservation;
@property int id;
@property OrderState state;
@property (retain) NSString *name;

@end
