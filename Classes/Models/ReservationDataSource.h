//
//  ReservationDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reservation.h"

@interface ReservationDataSource : NSObject <UITableViewDataSource>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
    bool includePlacedReservations;
}

@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;
@property bool includePlacedReservations;
@property (retain) NSDate* date;

+ (ReservationDataSource *) dataSource: (NSDate *)date includePlacedReservations: (bool) includePlaced;
- (Reservation *) getReservation: (NSIndexPath *) indexPath;
- (NSString *) keyForSection: (int)section;
- (int) countGuestsForKey: (NSString *)key;
- (int) countGuests;
- (void) createGroupedReservations;
- (void) tableView: (UITableView *) tableView includeSeated: (bool)showAll;
- (NSInteger)numberOfItemsInSlot: (NSMutableArray *)slot showAll: (bool) showAll;
- (NSString *) keyForReservation: (Reservation *)reservation;
- (void) addReservation: (Reservation*) reservation  fromTableView: (UITableView *)tableView;
- (void) deleteReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView;
- (void) updateReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView;
- (int) sectionForKey: (NSString *)searchKey;
- (int) getRow: (Reservation *) searchReservation inSlot: (NSMutableArray *)slot;
- (bool) isInCurrentTimeslot: (Reservation *)reservation;

@end
