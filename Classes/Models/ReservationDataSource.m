//
//  ReservationDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationDataSource.h"
#import "Service.h"
#import "Reservation.h"
#import "ReservationTableCell.h"

@implementation ReservationDataSource

@synthesize groupedReservations, reservations;

+ (ReservationDataSource *) dataSource
{
    ReservationDataSource *source = [[ReservationDataSource alloc] init];
    source.reservations = [[Service getInstance] getReservations];
    source.groupedReservations = [[NSMutableDictionary alloc] init];
    for (Reservation *reservation in source.reservations) {
        //  skip 'placed' reservations
        if(reservation.orderId != -1) continue;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];            
        NSString *timeSlot = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
        NSMutableArray *slotArray = [source.groupedReservations objectForKey:timeSlot];
        if(slotArray == nil) {
            slotArray = [[NSMutableArray alloc] init];
            [source.groupedReservations setObject:slotArray forKey:timeSlot];
        }
        [slotArray addObject:reservation];
    }
    return source;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return groupedReservations.count;
}	


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [[groupedReservations allKeys] objectAtIndex: section];
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    return slotReservations.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[groupedReservations allKeys] objectAtIndex: section];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ReservationTableCell *cell = (ReservationTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReservationTableCell" owner:self options:nil] lastObject];
    }
    
    NSString *key = [[groupedReservations allKeys] objectAtIndex: indexPath.section];
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    
    Reservation *reservation = [slotReservations objectAtIndex:indexPath.row];
    cell.reservation = reservation;
    return cell;
}


@end
