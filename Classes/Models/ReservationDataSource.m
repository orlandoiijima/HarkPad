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
    [source createGroupedReservations];
    return source;
}

- (void) createGroupedReservations
{
    self.groupedReservations = [[[NSMutableDictionary alloc] init] autorelease];
    for (Reservation *reservation in reservations) {
        [self addReservation:reservation fromTableView:nil];
    }
    
}

- (void) addReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView
{
    NSString *timeSlot = [self keyForReservation:reservation];
    NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
    if(slotArray == nil) {
        slotArray = [[[NSMutableArray alloc] init] autorelease];
        [groupedReservations setObject:slotArray forKey:timeSlot];
    }
    [slotArray addObject:reservation];
    if(tableView != nil)
    {
        [tableView beginUpdates];
        int section = [self sectionForKey:timeSlot];
        int row = [self numberOfItemsInSlot:slotArray showAll:includePlacedReservations] - 1;
        if(row == 0)
        {
            NSMutableIndexSet *insertIndexSet = [[[NSMutableIndexSet alloc] initWithIndex:section] autorelease];
            [tableView insertSections:insertIndexSet withRowAnimation:YES];
        }
        NSMutableArray *insertIndexPaths = [[[NSMutableArray alloc] init] autorelease];
        [insertIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
        [tableView insertRowsAtIndexPaths: insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [tableView endUpdates];	
    }
}

- (void) deleteReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView 
{
    NSString *timeSlot = [self keyForReservation:reservation];
    NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
    if(slotArray == nil) return;
    [slotArray removeObject:reservation];
    if(tableView != nil)
    {
        [tableView beginUpdates];
        int section = [self sectionForKey:timeSlot];
        int row = [self numberOfItemsInSlot:slotArray showAll:includePlacedReservations];
        if(row == 0)
        {
            NSMutableIndexSet *deleteIndexSet = [[[NSMutableIndexSet alloc] initWithIndex:section] autorelease];
            [tableView deleteSections:deleteIndexSet withRowAnimation:YES];
        }
        else
        {
            NSMutableArray *deleteIndexPaths = [[[NSMutableArray alloc] init] autorelease];
            [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
            [tableView deleteRowsAtIndexPaths: deleteIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [tableView endUpdates];	
    }
}

- (NSString *) keyForReservation: (Reservation *)reservation
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];            
    return [NSString stringWithFormat:@"%02d:%02d", hour, minute];
}

- (void) tableView: (UITableView *) tableView includeSeated: (bool)showAll
{
    [tableView beginUpdates];
    NSMutableIndexSet *insertIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *deleteIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for(int section = 0; section < [groupedReservations count]; section++)
    {
        NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *slotReservations = [groupedReservations objectForKey:key];
        int oldCount = [self numberOfItemsInSlot:slotReservations showAll: includePlacedReservations];
        int newCount = [self numberOfItemsInSlot:slotReservations showAll: showAll];
        if(oldCount == 0 && newCount > 0)
            [insertIndexSet addIndex:section];
        if(oldCount > 0 && newCount == 0)
        {
            [deleteIndexSet addIndex:section];
            continue;
        }
        int row = 0;
        for(Reservation *reservation in slotReservations)
        {
            if(reservation.isPlaced)
                if(showAll)
                    [insertIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
                else
                    [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
            row++;	
        }
    }
    includePlacedReservations = showAll;
	[tableView insertSections:insertIndexSet withRowAnimation:YES];
    [tableView deleteSections:deleteIndexSet withRowAnimation:YES];
    [tableView insertRowsAtIndexPaths: insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [tableView deleteRowsAtIndexPaths: deleteIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 0;
    for(NSMutableArray *slotReservations in [groupedReservations allValues])
        if([self numberOfItemsInSlot:slotReservations showAll:includePlacedReservations] > 0)
            count++;
    return count++;
}	

- (NSInteger)numberOfItemsInSlot: (NSMutableArray *)slot showAll: (bool) showAll
{
    NSInteger count = 0;
    for(Reservation *reservation in slot)
    {
        if(showAll || reservation.isPlaced == false)
            count++;
    }
    return count;
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
    int count = [slotReservations count];
    if(includePlacedReservations == false)
        for(Reservation *reservation in slotReservations)
        {
            if(reservation.orderId != -1)
                count--;
        }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

- (NSString *) keyForSection: (int)section
{
    if(groupedReservations.count == 0)
        return @"";
    NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int s = 0;
    for(NSString *key in sortedKeys)
    {
        NSMutableArray *slotReservations = [groupedReservations objectForKey:key];
        if([self numberOfItemsInSlot:slotReservations showAll:includePlacedReservations] > 0)
        {
            if(s == section) return key;
            s++;
        }
    }
    return nil;    
}

- (int) sectionForKey: (NSString *)searchKey
{
    NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int section = 0;
    for(NSString *key in sortedKeys)
    {
        NSMutableArray *slotReservations = [groupedReservations objectForKey:key];
        if([self numberOfItemsInSlot:slotReservations showAll:includePlacedReservations] > 0)
        {
            if([key isEqualToString:searchKey]) return section;
            section++;
        }
    }
    return -1;    
}
         
         
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    if(groupedReservations == nil || groupedReservations.count == 0)
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cellx"] autorelease];
        cell.textLabel.text = @"Geen reserveringen";
        return cell;
    }
    
    ReservationTableCell *cell = (ReservationTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReservationTableCell" owner:self options:nil] lastObject];
    }
    
    Reservation *reservation = [self getReservation:indexPath];
    NSString * cellTimeSlot = [self keyForSection:indexPath.section];
    UIColor *highlightColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1];
    cell.backgroundColor = [cellTimeSlot isEqualToString:[self currentTimeslot]] ? highlightColor : [UIColor whiteColor];
    cell.reservation = reservation;
    return cell;
}

- (Reservation *) getReservation: (NSIndexPath *) indexPath
{
    NSString *key = [self keyForSection: indexPath.section];
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    if(slotReservations == nil || indexPath.row >= [slotReservations count])
        return nil;
    int row = 0;
    for(int i = 0; i < [slotReservations count]; i++)
    {
        Reservation *reservation = [slotReservations objectAtIndex:i];
        if(includePlacedReservations == false)
           if(reservation.orderId != -1) continue;
        if(row == indexPath.row)
            return reservation;
        row++;
    }
    return nil;
}

- (NSString *) currentTimeslot
{
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:-1 fromDate:now];
    int minute = ([comps minute] + 10) - ([comps minute] + 10) % 30;
    int hour = [comps hour];
    if(minute == 60)
    {
        minute -= 60;
        hour++;
    }
    NSString *timeSlot =  [NSString stringWithFormat:@"%02d:%02d", hour, minute];
    return timeSlot;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        Reservation *reservation = [self getReservation:indexPath];
//        if(reservation == nil) return;
//        [[Service getInstance] deleteReservation: reservation.id];
//        //      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self refreshTable];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

@end
