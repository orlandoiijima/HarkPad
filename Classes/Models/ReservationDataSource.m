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
#import "NSDate-Utilities.h"

@implementation ReservationDataSource

@synthesize groupedReservations, reservations, includePlacedReservations, date, sortedKeys;
@dynamic isEmpty;

+ (ReservationDataSource *) dataSourceWithDate: (NSDate *)date includePlacedReservations: (bool) includePlaced withReservations: (NSMutableArray *)reservations
{
    ReservationDataSource *source = [[ReservationDataSource alloc] init];
    source.date = date;
    source.reservations = reservations;
    source.includePlacedReservations = includePlaced;
    [source createGroupedReservations];
    return source;
}

- (void) createGroupedReservations
{
    self.groupedReservations = [[NSMutableDictionary alloc] init];
    for (Reservation *reservation in reservations) {
        [self addReservation:reservation fromTableView:nil];
    }
    [self logDataSource];
}

- (void) logDataSource
{
    NSString *log = [NSString stringWithFormat: @"Source %@ ", self.date];
    for (NSString *key in [self.groupedReservations allKeys]) {
        log = [log stringByAppendingString:key];
        for (Reservation *reservation in [self.groupedReservations objectForKey:key]) {
            log = [log stringByAppendingString:[NSString stringWithFormat:@" %d", reservation.countGuests]];
        }
    }
}

- (void) addReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView
{
    NSString *timeSlot = [self keyForReservation:reservation];
    NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
    if(slotArray == nil) {
        slotArray = [[NSMutableArray alloc] init];
        [groupedReservations setObject:slotArray forKey:timeSlot];
    }
    [slotArray addObject:reservation];
    if(tableView != nil)
    {
        [tableView beginUpdates];
        NSInteger section = [self sectionForKey:timeSlot];
        NSInteger row = [self numberOfItemsInSlot:slotArray showAll:includePlacedReservations] - 1;
        if(row == 0)
        {
            NSMutableIndexSet *insertIndexSet = [[NSMutableIndexSet alloc] initWithIndex:(NSUInteger) section];
            [tableView insertSections:insertIndexSet withRowAnimation:YES];
        }
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        [insertIndexPaths addObject: [NSIndexPath indexPathForRow:(NSUInteger) row inSection:(NSUInteger) section]];
        [tableView insertRowsAtIndexPaths: insertIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [tableView endUpdates];
    }
}

- (void) deleteReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView 
{
    NSString *timeSlot = [self keyForReservation:reservation];
    NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
    if(slotArray == nil) return;

    if(tableView != nil)
    {
        [tableView beginUpdates];
        NSInteger section = [self sectionForKey:timeSlot];
        if([self numberOfItemsInSlot:slotArray showAll:includePlacedReservations] == 1)
        {
            NSMutableIndexSet *deleteIndexSet = [[NSMutableIndexSet alloc] initWithIndex:(NSUInteger) section];
            [tableView deleteSections:deleteIndexSet withRowAnimation:YES];
        }
        else
        {
            NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
            int row = [self getRow:reservation inSlot:slotArray];
            [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:(NSUInteger) row inSection:(NSUInteger) section]];
            [tableView deleteRowsAtIndexPaths: deleteIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }

    for (Reservation *reservationInSlot in slotArray) {
        if(reservationInSlot.id == reservation.id) {
            [slotArray removeObject:reservationInSlot];
            break;
        }
    }
    
    if(tableView != nil)
        [tableView endUpdates];	
}

- (void) updateReservation: (Reservation*) reservation fromTableView: (UITableView *)tableView 
{
    NSString *timeSlot = [self keyForReservation:reservation];
    NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
    if(slotArray == nil) return;

    for (int i = 0; i < [slotArray count]; i++)
    {
        Reservation *reservationInSlot = [slotArray objectAtIndex:i];
        if(reservationInSlot.id == reservation.id) {
            [slotArray replaceObjectAtIndex:i withObject:reservation];

            if(tableView != nil)
            {
                NSIndexPath *indexPath = [self getIndexPath:reservation inTable:tableView];
                if(indexPath != nil)
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
            break;
        }
    }
    
}


- (NSString *) keyForReservation: (Reservation *)reservation
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];     
    if(date == nil) {
        return [NSString stringWithFormat:@"%@ %02d:%02d", [reservation.startsOn prettyDateString], hour, minute];
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d", hour, minute];
    }
}

- (void) tableView: (UITableView *) tableView includeSeated: (bool)showAll
{
    [tableView beginUpdates];
    NSMutableIndexSet *insertIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *deleteIndexSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for(NSUInteger section = 0; section < [groupedReservations count]; section++)
    {
        NSString *key = [self.sortedKeys objectAtIndex:section];
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
        NSUInteger row = 0;
        for(Reservation *reservation in slotReservations)
        {
            if(reservation.isPlaced)
            {
                if(showAll)
                    [insertIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
                else
                    [deleteIndexPaths addObject: [NSIndexPath indexPathForRow:row inSection:section]];
            }
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
    return count;
}	

- (BOOL)isEmpty {
    for(NSMutableArray *slotReservations in [groupedReservations allValues])
        if([self numberOfItemsInSlot:slotReservations showAll:includePlacedReservations] > 0)
            return false;
    return true;
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
    int count = 0;
    if(groupedReservations != nil) {
        NSArray *slotReservations = [groupedReservations objectForKey:key];
        for(Reservation *reservation in slotReservations)
            count += reservation.countGuests;
    }
    return count;
}

- (int) countGuests
{
    int count = 0;
    if(groupedReservations != nil) {    
       for(NSMutableArray *slotReservations in [groupedReservations allValues])
            for(Reservation *reservation in slotReservations)
                count += reservation.countGuests;
    }
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
//    NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int s = 0;
    for(NSString *key in self.sortedKeys)
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
//    NSArray* sortedKeys = [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int section = 0;
    for(NSString *key in self.sortedKeys)
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

- (NSArray *) sortedKeys
{
    if(date == nil)
        return [groupedReservations allKeys];
    else
        return [[groupedReservations allKeys] sortedArrayUsingSelector:@selector(compare:)];
}
         
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    if(self.isEmpty)
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
    if (reservation == nil)
        return cell;
    UIColor *highlightColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1];
    cell.backgroundColor = [self isInCurrentTimeslot:reservation] ? highlightColor : [UIColor whiteColor];
    [cell setReservation: reservation];
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.status.hidden = true;
    
    if([reservation.startsOn isToday]) {
        if(reservation.orderState != OrderStateOrdering) {
            if(reservation.paidOn == nil || ([[NSDate date] timeIntervalSinceDate:reservation.paidOn] < 60*10))
                [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
                    cell.count.transform = CGAffineTransformMakeScale(1.20, 1.1);
                    cell.count.textColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1];
                    } completion:nil
                 ];
        }
    }
    
    return cell;
}

- (Reservation *) getReservation: (NSIndexPath *) indexPath
{
    if(groupedReservations == nil)
        return nil;
    NSString *key = [self keyForSection: indexPath.section];
    if([key length] == 0)
        return nil;
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    if(slotReservations == nil || indexPath.row >= [slotReservations count])
        return nil;
    int row = 0;
    for(NSUInteger i = 0; i < [slotReservations count]; i++)
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

- (NSIndexPath *) getIndexPath: (Reservation*) reservation inTable: (UITableView *)table
{
    for (int section = 0; section < [table numberOfSections]; section++) {
        for (int row = 0; row < [table numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            Reservation *r = [self getReservation: indexPath];
            if(r != nil) {
                if(r.id == reservation.id) {
                    return indexPath;
                }
            }
        }
    }
    return nil;
}

- (int) getRow: (Reservation *) searchReservation inSlot: (NSMutableArray *)slot
{
    int row = 0;
    for(NSUInteger i = 0; i < [slot count]; i++)
    {
        Reservation *reservation = [slot objectAtIndex:i];
        if(includePlacedReservations == false)
            if(reservation.orderId != -1) continue;
        if(searchReservation.id == reservation.id)
            return row;
        row++;
    }
    return -1;
}

- (bool) isInCurrentTimeslot: (Reservation *)reservation
{
    if(reservation == nil)
        return false;
    NSDate *now = [NSDate date];
    if([now isEqualToDateIgnoringTime: reservation.startsOn] == false)
        return false;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSUInteger) -1 fromDate:now];
    int minute = ([comps minute] + 10) - ([comps minute] + 10) % 30;
    int hour = [comps hour];
    if(minute == 60)
    {
        minute -= 60;
        hour++;
    }
    NSString *currentTimeSlot =  [NSString stringWithFormat:@"%02d:%02d", hour, minute];
    NSString * reservationTimeSlot = [self keyForReservation:reservation];
    return [currentTimeSlot isEqualToString:reservationTimeSlot];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    Reservation *reservation = [self getReservation:indexPath];
    if(reservation == nil) return;
    [[Service getInstance]
            deleteReservation: reservation.id
                      success: ^(ServiceResult *serviceResult) {
                                    [self deleteReservation:reservation fromTableView:tableView];
                                }
                        error: ^(ServiceResult *serviceResult) {
                            [serviceResult displayError];
                        }];
}


@end
