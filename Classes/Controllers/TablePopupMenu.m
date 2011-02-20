//
//  TablePopupMenu.m
//  HarkPad2
//
//  Created by Willem Bison on 30-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TablePopupMenu.h"
#import "OrderLineCell.h"
#import "TableMapViewController.h"
#import "Service.h"
#import "Utils.h"
#import "ReservationTableCell.h"

@implementation TablePopupMenu

@synthesize table, order, popoverController, tableInfoView, commandItems;
@synthesize reservations, groupedReservations;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

+ (TablePopupMenu *) menuForTable: (Table *) table withOrder: (Order *) order
{
    TablePopupMenu *tablePopupMenu = [[TablePopupMenu alloc] initWithStyle:UITableViewStyleGrouped];
    tablePopupMenu.table = table;
    tablePopupMenu.order = order;
    tablePopupMenu.tableInfoView = [TableInfoView viewWithOrder:order];
    
    tablePopupMenu.reservations = [[Service getInstance] getReservations];
    tablePopupMenu.groupedReservations = [[NSMutableDictionary alloc] init];
    for (Reservation *reservation in tablePopupMenu.reservations) {
        //  skip 'placed' reservations
        if(reservation.orderId != -1) continue;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];            
        NSString *timeSlot = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
        NSMutableArray *slotArray = [tablePopupMenu.groupedReservations objectForKey:timeSlot];
        if(slotArray == nil) {
            slotArray = [[NSMutableArray alloc] init];
            [tablePopupMenu.groupedReservations setObject:slotArray forKey:timeSlot];
        }
        [slotArray addObject:reservation];
    }
    
    return tablePopupMenu;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    commandItems = [[NSMutableDictionary alloc] init];
    [commandItems setValue:@"Bestelling opnemen" forKey: @"Bestelling"];
    if(order != nil)
    {
        Course *nextCourse = [order getNextCourse];
        if(nextCourse == nil)
            [commandItems setValue:@"Rekening opmaken" forKey: @"Rekening"];
        else
        {
            NSString *command = [NSString stringWithFormat: @"Gang %@ opvragen", [Utils getCourseChar: nextCourse.offset]];
            
            [commandItems setValue:command forKey: @"Gang"];
        }	
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(order == nil)
    {
        return 1 + groupedReservations.count;
    }
    else
        return 1;
}	


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section)
    {
        case 0:
        {
            if(order == nil)
                return 1;
            else
                return 2;
        }
        default:
        {
            NSString *key = [[groupedReservations allKeys] objectAtIndex: section - 1];
            NSArray *slotReservations = [groupedReservations objectForKey:key];
            
            return slotReservations.count;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section)
    {
        case 0:
            return [NSString stringWithFormat:@"Tafel %@", table.name];
            break;
        default:
        {
            return [[groupedReservations allKeys] objectAtIndex: section - 1];
        }
    }
    return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    switch(indexPath.section)
    {
            
        case 0:
        {            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            switch(indexPath.row)
            {
                case 0: cell.textLabel.text = @"Bestelling opnemen"; break;
                case 1:
                {
                    Course *nextCourse = [order getNextCourse];
                    if(nextCourse == nil)
                    {
                        cell.textLabel.text = @"Rekening opmaken";
                    }
                    else
                    {
                        cell.textLabel.text = [NSString stringWithFormat: @"Gang %@ opvragen", [Utils getCourseChar: nextCourse.offset]];
                        cell.detailTextLabel.text = [nextCourse stringForCourse];
                    }
                    break;
                }
            }
            return cell;
            break;
        }
          
        default:
        {
            ReservationTableCell *cell = (ReservationTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"ReservationTableCell" owner:self options:nil] lastObject];
            }

            NSString *key = [[groupedReservations allKeys] objectAtIndex: indexPath.section - 1];
            NSArray *slotReservations = [groupedReservations objectForKey:key];
            
            Reservation *reservation = [slotReservations objectAtIndex:indexPath.row];
            cell.reservation = reservation;
            return cell;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    TableMapViewController *tableMapController = (TableMapViewController*) popoverController.delegate;
                    if(order == nil)
                        [tableMapController newOrderForTable: table];
                    else
                        [tableMapController editOrder:order];
                    [popoverController dismissPopoverAnimated:YES];
                    return;
                }
                case 1:
                {
                    Course *nextCourse = [order getNextCourse];
                    if(nextCourse == nil)
                    {
                        [[Service getInstance] makeBills:nil forOrder: order.id]; 
                        [popoverController dismissPopoverAnimated:YES];
                    }
                    else
                    {
                        [[Service getInstance] startCourse: nextCourse.id]; 
                        [popoverController dismissPopoverAnimated:YES];
                    }
                    return;
                }
            }
        }
        default:
        {
            NSString *key = [[groupedReservations allKeys] objectAtIndex: indexPath.section - 1];
            NSArray *slotReservations = [groupedReservations objectForKey:key];
            
            Reservation *reservation = [slotReservations objectAtIndex:indexPath.row];
            TableMapViewController *tableMapController = (TableMapViewController*) popoverController.delegate;
            [tableMapController startTable: table fromReservation: reservation];
            return;
        }
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

