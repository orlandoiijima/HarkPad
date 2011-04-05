//
//  TablePopupViewController.m
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "TablePopupViewController.h"
#import "TableMapViewController.h"
#import "ReservationDataSource.h"
#import "Utils.h"

@implementation TablePopupViewController

@synthesize tableReservations, labelNextCourse, buttonGetPayment, buttonMakeBill, buttonMakeOrder, buttonStartCourse, labelTable, labelReservations, popoverController;
@synthesize reservationDataSource, table, order, labelReservationNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


+ (TablePopupViewController *) menuForTable: (Table *) table withOrder: (Order *) order
{
    TablePopupViewController *tablePopupMenu = [[TablePopupViewController alloc] initWithNibName:@"TablePopupViewController" bundle:[NSBundle mainBundle]];
    tablePopupMenu.table = table;
    tablePopupMenu.order = order;
       
    if(order == nil) {
        tablePopupMenu.reservationDataSource = [ReservationDataSource dataSource];
    }
    
    return tablePopupMenu;
}

- (TableMapViewController *) tableMapController
{
    return (TableMapViewController*) popoverController.delegate;
}

- (void) setPreferredSize
{
    if(order != nil || reservationDataSource == nil || [reservationDataSource.groupedReservations count] == 0) {
        //  Existing order or no reservations: remove table + label
        [reservationsTable removeFromSuperview];
        [labelReservations removeFromSuperview];
        
        if(order.reservation == nil || order.reservation.notes == nil) {
            //  Not based on reservation or no note
            [labelReservationNote removeFromSuperview];
            self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width, 195);
            self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width, buttonMakeBill.frame.origin.y + buttonMakeBill.frame.size.height + 10);
        }
        else {
            self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width, labelReservationNote.frame.origin.y + labelReservationNote.frame.size.height + 10);
        }
    }
    else
        self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (IBAction) getOrder
{
    if(order == nil)
        [[self tableMapController] newOrderForTable: table];
    else
        [[self tableMapController] editOrder:order];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (IBAction) startNextCourse
{
    [[self tableMapController] startNextCourse:order];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (IBAction) makeBill
{
    [[self tableMapController ] makeBills:order];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (IBAction) getPayment
{
    [[self tableMapController] payOrder:order];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (void) placeReservation: (Reservation*)reservation
{
    [[self tableMapController] startTable: table fromReservation: reservation];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    tableReservations.dataSource = reservationDataSource;
    tableReservations.delegate = self;
    
    labelTable.text = [NSString stringWithFormat:@"Tafel %@", table.name];
    
    Course *nextCourse = [order getNextCourse];
    if(nextCourse != nil) {
        [buttonStartCourse setTitle:[NSString stringWithFormat: @"Gang %@: %@", [Utils getCourseChar: nextCourse.offset], [nextCourse stringForCourse]] forState:UIControlStateNormal ];
    }
    else {
        [buttonStartCourse setTitle:@"Geen volgende gang" forState:UIControlStateDisabled];
        [self setButton:buttonStartCourse enabled: false];
        labelNextCourse.text = @"";
    }
    
    [self setButton: buttonGetPayment enabled: order.state == billed];
    [self setButton: buttonMakeOrder enabled: order == nil || order.state == ordering];
    [self setButton: buttonMakeBill enabled: order.state != billed];
    
    if(order.reservation != nil) {
        [tableReservations removeFromSuperview];
        [labelReservations removeFromSuperview];
        labelReservationNote.text = order.reservation.notes;
    }
    else {
        [labelReservationNote removeFromSuperview];
    }
    [self setPreferredSize];
}

- (void) setButton: (UIButton*) button enabled: (bool)enabled
{
    button.enabled = enabled;
//    button.titleLabel.textColor = enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
    button.titleLabel.textColor = [button.titleLabel.textColor colorWithAlphaComponent:enabled ? 1: 0.5];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[reservationDataSource.groupedReservations allKeys] objectAtIndex: indexPath.section];
    NSArray *slotReservations = [reservationDataSource.groupedReservations objectForKey:key];
            
    Reservation *reservation = [slotReservations objectAtIndex:indexPath.row];
    [self placeReservation:reservation];
}



@end
