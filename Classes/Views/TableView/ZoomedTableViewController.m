//
//  ZoomedTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoomedTableViewController.h"
#import "SelectReservationView.h"

@interface ZoomedTableViewController ()

@end

@implementation ZoomedTableViewController

@synthesize tableWithSeatsView, order, reservationDataSource, selectedGuest = _selectedGuest, tableViewDashboard, delegate, selectedSeat = _selectedSeat, saveSelectedSeat = _saveSelectedSeat;

+ (ZoomedTableViewController *) controllerWithTableView:(TableWithSeatsView *) tableWithSeatsView delegate:(id)delegate {
    ZoomedTableViewController *controller = [[ZoomedTableViewController alloc] init];
    controller.delegate = delegate;
    controller.tableWithSeatsView = tableWithSeatsView;
    [[Service getInstance] getOpenOrderByTable: tableWithSeatsView.table.id delegate:controller callback:@selector(getOpenOrderByTableCallback:)];
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[TableOverlayDashboard alloc] initWithFrame:CGRectInset(tableWithSeatsView.tableView.bounds, 0, 0) tableView:tableWithSeatsView order:order delegate: self];
    self.view.hidden = YES;
    tableWithSeatsView.contentTableView = self.view;
}

- (TableOverlayDashboard *)tableViewDashboard
{
    return (TableOverlayDashboard *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableWithSeatsView.delegate = self;
}

- (void)didChangeToPageView:(UIView *)view {
    if ([view isKindOfClass:[GuestProperties class]]) {
        self.selectedSeat = self.saveSelectedSeat;
    }
    else
    if (self.selectedSeat != -1) {
        self.saveSelectedSeat = self.selectedSeat;
        self.selectedSeat = -1;
    }
}

- (void)didTapCloseButton {
    if([self.delegate respondsToSelector:@selector(didTapCloseButton)])
        [self.delegate didTapCloseButton];
}

-(void) getOpenOrderByTableCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }

    order = serviceResult.data;
    if(order == nil) {
        order = [Order orderForTable:tableWithSeatsView.table];
        for(Guest *guest in order.guests) {
            SeatView *seatView = [tableWithSeatsView seatViewAtOffset:guest.seat];
            [seatView initByGuest: guest];
        }
    }
    [[Service getInstance] getReservations: [NSDate date] delegate:self callback:@selector(getReservationsCallback:onDate:)];
    self.tableViewDashboard.actionsView.order = order;
    self.tableViewDashboard.infoView.order = order;
    self.tableViewDashboard.courseInfo.order = order;
}

- (void)getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date {
    NSMutableArray *reservations = serviceResult.data;
    if ([reservations count] == 0) {
    }
    Reservation *walkinReservation = [[Reservation alloc] init];
    walkinReservation.type = ReservationTypeWalkin;
    walkinReservation.id = -1;
    walkinReservation.startsOn = [NSDate date];
    walkinReservation.countGuests = order.table.countSeatsTotal;
    walkinReservation.name = NSLocalizedString(@"Walk-in", nil);
    [reservations addObject:walkinReservation];
    if (order.reservation != nil) {
        for (Reservation *reservation in reservations)
            if (reservation.id == order.reservation.id) {
                reservation.orderId = -1;
            }
    }
    reservationDataSource = [ReservationDataSource dataSourceWithDate: date includePlacedReservations:NO withReservations: reservations];
    self.tableViewDashboard.reservationsTableView.dataSource = reservationDataSource;
    self.tableViewDashboard.reservationsTableView.selectedReservation = order.reservation == nil ? walkinReservation : order.reservation;
}

- (void)editOrder {
    if (self.delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(editOrder:)])
        [self.delegate editOrder:order];
}

- (void)makeBillForOrder {
    if (self.delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(makeBillForOrder:)])
        [self.delegate makeBillForOrder: order];
}

- (void)getPaymentForOrder {
    if (self.delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(getPaymentForOrder:)])
        [self.delegate getPaymentForOrder: order];
}

- (void)startNextCourse {
    if (self.delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(startNextCourseForOrder:)])
        [self.delegate startNextCourseForOrder: order];
}

- (void) tapDiet:(id) sender
{
    if (_selectedGuest == nil) return;
    ToggleButton *toggleButton = (ToggleButton *)sender;
    if (toggleButton == nil) return;
    if (toggleButton.isOn)
        _selectedGuest.diet |= toggleButton.tag;
    else
        _selectedGuest.diet &= ~toggleButton.tag;

    [self refreshSeatView];
//    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
//        [self.delegate didModifyItem:selectedGuest];
}

- (void) tapGender: (id)sender {
    if (_selectedGuest == nil) {
        return;
    }
    ToggleButton *seatView = (ToggleButton *)sender;
    if (seatView == nil) return;
    GuestProperties *propView = self.tableViewDashboard.guestProperties;
    propView.viewMale.isOn = seatView == propView.viewMale;
    propView.viewFemale.isOn = seatView == propView.viewFemale;
    propView.viewEmpty.isOn = seatView == propView.viewEmpty;
    _selectedGuest.isMale = propView.viewMale.isOn;
    _selectedGuest.isEmpty = propView.viewEmpty.isOn;

    [self refreshSeatView];

//    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
//        [self.delegate didModifyItem: selectedGuest];
}

- (void) tapHost: (id)sender {
    if (_selectedGuest == nil) return;
    ToggleButton *isHostView = (ToggleButton *)sender;
    _selectedGuest.isHost = isHostView.isOn;

    [self refreshSeatView];

//    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
//        [self.delegate didModifyItem: selectedGuest];
}

- (void)didTapSeat: (int)offset {
    self.selectedSeat = self.saveSelectedSeat = offset;
    [self.tableViewDashboard scrollToView: self.tableViewDashboard.guestProperties];
}

- (BOOL) canSelectSeat: (int)offset {
    return YES;
}

- (BOOL) canSelectTableView: (TableWithSeatsView *)tableView {
    return NO;
}

- (void)setSelectedSeat: (int)seat
{
    _selectedSeat = seat;
    self.selectedGuest = [order getGuestBySeat:seat];
    [self.tableWithSeatsView selectSeat:seat];
    self.tableViewDashboard.guestProperties.guest = _selectedGuest;
}

- (void)didSelectItem:(id)item {
    Reservation *reservation = (Reservation *)item;
    if (reservation == nil) return;
    order.reservation = reservation;
}

- (void) refreshSeatView
{
    SeatView *seatView = [tableWithSeatsView seatViewAtOffset: _selectedSeat];
    [seatView initByGuest: _selectedGuest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
