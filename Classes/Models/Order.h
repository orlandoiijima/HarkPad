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
#import "User.h"
#import "DTO.h"

typedef enum OrderGrouping {noGrouping, bySeat, byCourse, byCategory} OrderGrouping ;
typedef enum OrderState {
    OrderStateOrdering, OrderStateBilled, OrderStatePaid
} OrderState ;
typedef enum PaymentType {UnPaid, Cash, Pin, CreditCard} PaymentType ;

@interface Order : DTO {
//    EntityState entityState;
    NSMutableArray *courses;
    NSMutableArray *guests;
    NSMutableArray *lines;
    Reservation *reservation;
    NSDate *createdOn;
    NSDate *paidOn;
    NSString *name;
    Table *table;
    PaymentType paymentType;
//    int id;
    OrderState state;
    User *invoicedTo;
}


+ (Order *) orderForTable: (Table *) table;
+ (Order *) orderFromJsonDictionary: (NSDictionary *)jsonDictionary;
+ (Order *) orderNull;
- (NSMutableDictionary *)toDictionary;
- (NSDecimalNumber *)totalAmount;
- (OrderLine *) addLineWithProductId: (int) productId seat: (int) seat course: (int) course;

- (Course *) getCourseByOffset: (int)offset;
- (Guest *) getGuestBySeat: (int)seat;
- (BOOL) isCourseAlreadyRequested: (int) courseOffset;
- (void)addOrderLine: (OrderLine *)line;
- (void)removeOrderLine: (OrderLine *)line;
- (Course *) addCourse;
- (Guest *) addGuest;

//@property EntityState entityState;
@property (retain) NSMutableArray *courses;
@property (retain) NSMutableArray *guests;
@property (retain) NSMutableArray *lines;
@property (retain) NSDate *createdOn;
@property (retain) NSDate *paidOn;
@property (retain) Table *table;
@property PaymentType paymentType;
@property (retain) Reservation *reservation;
//@property int id;
@property OrderState state;
@property (retain) NSString *name;
@property (retain) User *invoicedTo;
@property (assign) Course *currentCourse;
@property (retain) Course *lastCourse;
@property (retain) Course *nextCourseToRequest;
@property (retain) Course *nextCourseToServe;
@property int lastSeat;
@property (retain) Guest *firstGuest;
@end
