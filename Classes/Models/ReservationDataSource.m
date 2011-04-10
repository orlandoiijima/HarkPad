//
//  ReservationDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationDataSource.h"
#import "Service.h"
#import "ReservationTableCell.h"

@implementation ReservationDataSource

@synthesize groupedReservations, reservations, includePlacedReservations;

+ (ReservationDataSource *) dataSource: (NSDate *)date includePlacedReservations: (bool) includePlaced
{
    ReservationDataSource *source = [[ReservationDataSource alloc] init];
    source.reservations = [[Service getInstance] getReservations: date];
    source.includePlacedReservations = includePlaced;
//    [source createGroupedReservations];
    return source;
}

- (void) createGroupedReservations
{
    groupedReservations = [[NSMutableDictionary alloc] init];
    for (Reservation *reservation in reservations) {
        if(includePlacedReservations == false)
            if(reservation.orderId != -1) continue;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];            
        NSString *timeSlot = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
        NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
        if(slotArray == nil) {
            slotArray = [[NSMutableArray alloc] init];
            [groupedReservations setObject:slotArray forKey:timeSlot];
        }
        [slotArray addObject:reservation];
    }
    
}

- (void) setIncludePlacedReservations:(_Bool)include
{
    includePlacedReservations = include;
    [self createGroupedReservations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return groupedReservations.count;
}	

- (int) countGuestsForKey: (NSString *)key
{
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    if(groupedReservations == nil) return 0;
    int count = 0;
    for(Reservation *reservation in slotReservations)
        count += reservation.countGuests;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self keyForSection:section];
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    return [slotReservations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

- (NSString *) keyForSection: (int)section
{
    if(groupedReservations.count == 0)
        return @"";
    NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];    
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    NSString *key = [self keyForSection:section];
//    return [NSString stringWithFormat:@"Aantal gasten %@: %d", key, [self countGuestsForKey:key]];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    if(groupedReservations == nil || groupedReservations.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cellx"];
        cell.textLabel.text = @"Geen reserveringen";
        return cell;
    }
    
    ReservationTableCell *cell = (ReservationTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReservationTableCell" owner:self options:nil] lastObject];
    }
    
    Reservation *reservation = [self getReservation:indexPath];
    cell.reservation = reservation;
    return cell;
}

- (Reservation *) getReservation: (NSIndexPath *) indexPath
{
    NSString *key = [self keyForSection: indexPath.section];
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    if(slotReservations == nil || indexPath.row >= [slotReservations count])
        return nil;
    return [slotReservations objectAtIndex:indexPath.row];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Reservation *reservation = [self getReservation:indexPath];
        if(reservation == nil) return;
        [[Service getInstance] deleteReservation: reservation.id];
        //      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self refreshTable];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
