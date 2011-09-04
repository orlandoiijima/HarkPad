	//
//  TablePopupViewController.m
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "TablePopupViewController.h"
#import "Utils.h"

@implementation TablePopupViewController

@synthesize tableReservations, buttonGetPayment, buttonMakeBill, buttonMakeOrder, buttonStartCourse, labelTable, labelReservations, popoverController;
@synthesize 	table, order, labelReservationNote, buttonUndockTable, buttonTransferOrder, reservationDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (ReservationDataSource *)reservationDataSource
{
    return (ReservationDataSource *) tableReservations.dataSource;
}

- (void)setReservationDataSource:(ReservationDataSource *)dataSource
{
    reservationDataSource = dataSource;
    tableReservations.dataSource = dataSource;
}

+ (TablePopupViewController *) menuForTable: (Table *) table
{
    TablePopupViewController *tablePopupMenu = [[TablePopupViewController alloc] initWithNibName:@"TablePopupViewController" bundle:[NSBundle mainBundle]];
    tablePopupMenu.table = table;
    
    [[Service getInstance] getOpenOrderByTable:table.id delegate:tablePopupMenu callback:@selector(getOpenOrderByTableCallback:)];
    
    return tablePopupMenu;
}

-(void) getOpenOrderByTableCallback: (Order *)tableOrder
{
    self.order = tableOrder;
    
    [self updateOnOrder];
    if(order == nil) {
        [[Service getInstance] getReservations: nil delegate:self callback:@selector(getReservationsCallback:onDate:)];
    }
}

- (TableMapViewController *) tableMapController
{
    return (TableMapViewController*) popoverController.delegate;
}

- (void) setOptimalSize
{
    if(order != nil || self.reservationDataSource == nil || [self.reservationDataSource isEmpty]) {
        if(order.reservation == nil || order.reservation.notes == nil || [order.reservation.notes length] == 0) {
            //  Not based on reservation or no note
            self.contentSizeForViewInPopover = [self getSizeFromBottomItem: buttonMakeBill];
        }
        else {
            self.contentSizeForViewInPopover = [self getSizeFromBottomItem: labelReservationNote];
        }
    }
    else {
        self.contentSizeForViewInPopover = [self getSizeFromBottomItem: tableReservations];
    }
}

- (CGSize) getSizeFromBottomItem: (UIView *)bottomView
{
    return CGSizeMake(self.view.bounds.size.width, bottomView.frame.origin.y + bottomView.frame.size.height + 15);
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
    [self.tableMapController startNextCourse:order];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (IBAction) undockTable
{
    [[self tableMapController] undockTable:table.id];
    [popoverController dismissPopoverAnimated:YES];
    return;
}

- (IBAction) transferOrder
{
    [[self tableMapController] transferOrder: order.id];
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


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) updateOnOrder
{
    Course *nextCourse = nil;
    bool allCoursesDone = false;
    if(order != nil && order.state == ordering) {
        nextCourse = [order getNextCourse];
        if(nextCourse != nil) {
            [buttonStartCourse setTitle:[NSString stringWithFormat: @"Gang %@: %@", [Utils getCourseChar: nextCourse.offset], [nextCourse stringForCourse]] forState:UIControlStateNormal ];
        }
        else {
            if([order.courses count] > 0)
                allCoursesDone = true;
        }
    }
    
    [self setButton: buttonStartCourse state: nextCourse != nil ? highlighted : disabled];
    [self setButton: buttonGetPayment state: order.state == billed ? highlighted : disabled];
    [self setButton: buttonMakeBill state: order.state == billed ? special : disabled];
    [self setButton: buttonMakeOrder state: order == nil || order.state == ordering ? highlighted : disabled];
    [self setButton: buttonMakeBill state: order == nil ? disabled : (allCoursesDone ? highlighted : (order.state == billed ? special : enabled))];
    [self setButton: buttonTransferOrder state: order == nil ? disabled : enabled];
    
	    if(order.reservation != nil) {
        [tableReservations removeFromSuperview];
        [labelReservations removeFromSuperview];
        labelReservationNote.text = order.reservation.notes;
    }
    else {
        [labelReservationNote removeFromSuperview];
    }
    
    [self setOptimalSize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    tableReservations.delegate = self;
    
    labelTable.text = [NSString stringWithFormat:@"Tafel %@", table.name];
    
    if(self.table.isDocked) {
//	        buttonMakeOrder.frame = CGRectMake(buttonMakeOrder.frame.origin.x, buttonMakeOrder.frame.origin.y, buttonMakeBill.bounds.size.width, buttonMakeOrder.bounds.size.height);
    }
    else {
        buttonMakeOrder.frame = CGRectMake(buttonMakeOrder.frame.origin.x, buttonMakeOrder.frame.origin.y, buttonStartCourse.bounds.size.width, buttonMakeOrder.bounds.size.height);
        [buttonUndockTable removeFromSuperview];	
    }

    [self setOptimalSize];
}

- (void) getReservationsCallback: (NSMutableArray *)reservations onDate: (NSDate *)date
{
    self.reservationDataSource = [ReservationDataSource dataSource:[NSDate date] includePlacedReservations:NO withReservations:reservations];
    [tableReservations reloadData];
    [self setOptimalSize];
}

- (void) setButton: (UIButton*) button state: (buttonState) state
{
    button.enabled = state != disabled;
    button.titleLabel.textColor = [button.titleLabel.textColor colorWithAlphaComponent: button.enabled ? 1: 0.5];
    button.tintColor = state == special ? [UIColor redColor] : (state == highlighted ? [UIColor blueColor] : [UIColor blackColor]);
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
    Reservation *reservation = [self.reservationDataSource getReservation:indexPath];
    [self placeReservation:reservation];
}



@end
