//
//  ReservationDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reservation.h"

@interface ReservationDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
    bool includePlacedReservations;
}

@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;
@property bool includePlacedReservations;
+ (ReservationDataSource *) dataSource: (NSDate *)date includePlacedReservations: (bool) includePlaced;
- (Reservation *) getReservation: (NSIndexPath *) indexPath;
- (NSString *) keyForSection: (int)section;
- (int) countGuestsForKey: (NSString *)key;
- (void) createGroupedReservations;
- (NSString *) currentTimeslot;

@end
