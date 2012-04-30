//
//  ZoomedTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 02/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ZoomedTableViewController.h"
#import "SelectReservationView.h"
#import "ModalAlert.h"

@interface ZoomedTableViewController ()

@end

@implementation ZoomedTableViewController

@synthesize tableWithSeatsView, order, reservationDataSource, selectedGuest = _selectedGuest, tableViewDashboard, delegate, selectedSeat = _selectedSeat, saveSelectedSeat = _saveSelectedSeat,  dragSeatView, dragPosition, dragOriginalFrame;

+ (ZoomedTableViewController *) controllerWithTableView:(TableWithSeatsView *) tableWithSeatsView delegate:(id)delegate {
    ZoomedTableViewController *controller = [[ZoomedTableViewController alloc] init];
    controller.delegate = delegate;
    controller.tableWithSeatsView = tableWithSeatsView;
    controller.view.hidden = NO;
    [[Service getInstance] getOpenOrderByTable: tableWithSeatsView.table.id delegate:controller callback:@selector(getOpenOrderByTableCallback:)];

    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:controller action:@selector(handlePanGesture:)];
    [tableWithSeatsView addGestureRecognizer:recognizer];
    return controller;
}

- (void) handlePanGesture: (UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint point = [panGestureRecognizer locationInView: tableWithSeatsView];
    switch(panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            UIView *view = [tableWithSeatsView hitTest:point withEvent:0];
            if ([view isKindOfClass:[SeatView class]])
            {
                dragSeatView = view;
                [dragSeatView.superview bringSubviewToFront:dragSeatView];
                dragPosition = point;
                dragOriginalFrame = view.frame;
            }
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            if (dragSeatView == nil) return;
            dragSeatView.center = CGPointMake(dragSeatView.center.x + point.x - dragPosition.x, dragSeatView.center.y + point.y - dragPosition.y);
            dragPosition = point;
            SeatView *targetSeatView = [tableWithSeatsView seatViewAtPoint: point exclude: dragSeatView];
            if (targetSeatView != nil) {
            }
            else {
            }
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            int beforeSeat = NSNotFound;
            int seatToMove = dragSeatView.offset;
            TableSide tableSide = NSNotFound;
            SeatView *targetSeatView = [tableWithSeatsView seatViewAtPoint: point exclude: dragSeatView];
            if (targetSeatView == nil) {
                tableSide = [tableWithSeatsView tableSideSeatSectionAtPoint:point];
                if (tableSide != NSNotFound) {
                    beforeSeat = [tableWithSeatsView.table firstSeatAtSide:tableSide];
                }
            }
            else {
                beforeSeat = targetSeatView.offset;
                tableSide = targetSeatView.side;
                switch (targetSeatView.side) {
                    case TableSideTop:
                        if (dragSeatView.center.x > targetSeatView.center.x)
                            beforeSeat++;
                        break;
                    case TableSideRight:
                        if (dragSeatView.center.y > targetSeatView.center.y)
                            beforeSeat++;
                        break;
                    case TableSideBottom:
                        if (dragSeatView.center.x < targetSeatView.center.x)
                            beforeSeat++;
                        break;
                    case TableSideLeft:
                        if (dragSeatView.center.y < targetSeatView.center.y)
                            beforeSeat++;
                        break;
                }
            }
            if (beforeSeat != NSNotFound) {
                if (dragSeatView == tableWithSeatsView.spareSeatView) {
                    [[Service getInstance] insertSeatAtTable:tableWithSeatsView.table.id beforeSeat: beforeSeat atSide: tableSide delegate:self callback:@selector(insertSeatCallback:)];
                }
                else {
                    [tableWithSeatsView moveSeat: seatToMove toSeat:beforeSeat atSide:tableSide];
                    [[Service getInstance] moveSeat: seatToMove atTable:tableWithSeatsView.table.id beforeSeat: beforeSeat atSide: tableSide delegate:self callback:@selector(moveSeatCallback:)];
                }
            }
            else {
                if (dragSeatView == tableWithSeatsView.spareSeatView) {
                    [self revertDrag];
                }
                else {
                    bool continueDelete = [ModalAlert confirm:NSLocalizedString(@"Delete seat ?", <#comment#>)];
                    if(continueDelete) {
                        [tableWithSeatsView removeSeat: seatToMove];
                        [[Service getInstance] deleteSeat: seatToMove fromTable:tableWithSeatsView.table.id delegate:self callback:@selector(deleteSeatCallback:)];
                    }
                    else
                        [self revertDrag];
                }
            }
            break;
        }

        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            break;
    }
}

- (void) insertSeatCallback:(ServiceResult *) serviceResult {
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];

        [self revertDrag];
        return;
    }
}

- (void) deleteSeatCallback:(ServiceResult *) serviceResult {
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];

        [self revertDrag];
        return;
    }
}

- (void) moveSeatCallback:(ServiceResult *) serviceResult {
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];

        [self revertDrag];
        return;
    }
}

- (void) revertDrag {
    [UIView animateWithDuration:0.3
                     animations:^{
                         dragSeatView.frame = dragOriginalFrame;
                     }
                    completion:^(BOOL x){
                        dragSeatView = nil;
            }
    ];
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
    tableWithSeatsView.contentTableView = self.view;
    tableWithSeatsView.spareSeatView.center = CGPointMake(tableWithSeatsView.center.x, tableWithSeatsView.center.y + 100);
    tableWithSeatsView.spareSeatView.hidden = NO;
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
    [self endZoom];
}

- (void) endZoom {
    [[Service getInstance] updateOrder: order delegate: nil callback:nil];

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
    [self.tableViewDashboard gotoView: self.tableViewDashboard.guestProperties];
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
