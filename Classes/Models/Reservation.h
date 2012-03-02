//
//  Reservation.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Table.h"
#import "Cache.h"

typedef enum ReservationType {
    ReservationTypeOnline = 0, ReservationTypePhone, ReservationTypeWalkin
} ReservationType;

@interface Reservation : NSObject{
    int id;
    NSString *name;
    NSString *phone;
    NSString *email;
    NSString *notes;
    NSString *language;
    NSDate *startsOn;
    NSDate *endsOn;
    NSDate *createdOn;
    int countGuests;
    BOOL mailingList;
    ReservationType type;
    int orderId;
    int orderState;
    NSDate *paidOn;
    Table *table;
}

@property int id;
@property (retain) NSString *name;
@property (retain) NSString *phone;
@property (retain) NSString *email;
@property (retain) NSString *notes;
@property (retain) NSString *language;
@property (retain) NSDate *startsOn;
@property (retain) NSDate *endsOn;
@property (retain) NSDate *createdOn;
@property (retain) Table *table;
@property int countGuests;
@property ReservationType type;
@property BOOL mailingList;
@property int orderId;
@property int orderState;
@property (retain) NSDate *paidOn;

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary;
+ (Reservation *)null;

- (NSMutableDictionary *)toDictionary;
- (bool) isPlaced;
- (BOOL) isNullReservation;

@end
