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

    controller.view = [[TableOverlayDashboard alloc] initWithFrame:CGRectInset(tableWithSeatsView.tableView.bounds, 0, 0) tableView:tableWithSeatsView delegate: controller];
    tableWithSeatsView.contentTableView = controller.view;
    tableWithSeatsView.delegate = controller;
    [tableWithSeatsView.superview bringSubviewToFront:tableWithSeatsView];
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
                dragSeatView = (SeatView *)view;
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
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            int beforeSeat = [tableWithSeatsView seatAtPoint:point];
            int seatToMove = dragSeatView.offset;
            TableSide tableSide = NSNotFound;
            if (beforeSeat == NSNotFound) {
                tableSide = [tableWithSeatsView tableSideSeatSectionAtPoint:point];
                if (tableSide != NSNotFound) {
                    beforeSeat = [tableWithSeatsView.table firstSeatAtSide:tableSide];
                }
            }
            else {
                CGRect seatFrame = [tableWithSeatsView frameForSeat:beforeSeat];
                tableSide = [tableWithSeatsView.table sideForSeat:beforeSeat];
                switch (tableSide) {
                    case TableSideTop:
                        if (dragSeatView.center.x > CGRectGetMidX(seatFrame))
                            beforeSeat++;
                        break;
                    case TableSideRight:
                        if (dragSeatView.center.y > CGRectGetMidY(seatFrame))
                            beforeSeat++;
                        break;
                    case TableSideBottom:
                        if (dragSeatView.center.x < CGRectGetMidX(seatFrame))
                            beforeSeat++;
                        break;
                    case TableSideLeft:
                        if (dragSeatView.center.y < CGRectGetMidY(seatFrame))
                            beforeSeat++;
                        break;
                }
            }
            if (beforeSeat != NSNotFound) {
                if (dragSeatView == tableWithSeatsView.spareSeatView) {
                    [tableWithSeatsView insertSeatBeforeSeat:beforeSeat atSide:tableSide];
                    [[Service getInstance] insertSeatAtTable:tableWithSeatsView.table.id beforeSeat: beforeSeat atSide: tableSide delegate:self callback:@selector(insertSeatCallback:)];
                }
                else {
                    if(dragSeatView.side == tableSide && (dragSeatView.offset == beforeSeat || dragSeatView.offset + 1 == beforeSeat))
                        [self revertDrag];
                    else {
                        [tableWithSeatsView moveSeat: seatToMove toSeat:beforeSeat atSide:tableSide];
                        [[Service getInstance] moveSeat: seatToMove atTable:tableWithSeatsView.table.id beforeSeat: beforeSeat atSide: tableSide delegate:self callback:@selector(moveSeatCallback:)];
                    }
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

- (TableOverlayDashboard *)tableViewDashboard
{
    return (TableOverlayDashboard *)self.view;
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
    [self updateOrder];
    [self endZoom];
}

- (void) endZoom {
//    if([self.delegate respondsToSelector:@selector(didTapCloseButton)])
//    [self.delegate updateOrder:order];
    [self.delegate closePopup];
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
    else {
        order.table = tableWithSeatsView.table;
    }
    [[Service getInstance] getReservations: [NSDate date] delegate:self callback:@selector(getReservationsCallback:onDate:)];
    self.tableViewDashboard.order = order;
    self.tableWithSeatsView.orderInfo = order;
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

- (void)updateOrder {
    if (self.delegate == nil) return;
    if([self.delegate respondsToSelector:@selector(updateOrder:)])
        [self.delegate updateOrder: order];
}
//
//- (void)startNextCourse {
//    if (self.delegate == nil) return;
//    if([self.delegate respondsToSelector:@selector(startNextCourseForOrder:)])
//        [self.delegate startNextCourseForOrder: order];
//}

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
    if (propView.viewMale.isOn)
        _selectedGuest.guestType = guestMale;
    else if (propView.viewFemale.isOn)
        _selectedGuest.guestType = guestFemale;
    else
        _selectedGuest.guestType = guestEmpty;

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
    Guest *guest = [order getGuestBySeat:seat];
    if(guest == nil) {
        guest = [order addGuest];
        guest.seat = seat;
        guest.guestType = guestEmpty;
    }
    self.selectedGuest = [order getGuestBySeat:seat];
    [self.tableWithSeatsView selectSeat:seat];
    self.tableViewDashboard.guestProperties.guest = _selectedGuest;
}

- (void) makeBillForOrder: (Order *) o {
    [self.delegate makeBillForOrder:o];
}
- (void) getPaymentForOrder: (Order *) o {
    [self.delegate getPaymentForOrder:o];
}

- (void) startNextCourseForOrder: (Order *) o {
    [self.delegate startNextCourseForOrder:o];
}

- (void) editOrder:(Order *)o {
    [self.delegate editOrder:o];
}

- (void) updateOrder:(Order *)o {
    [self.delegate updateOrder:o];
}

- (void) closePopup {
    [self.delegate closePopup];
}

//- (void)didSelectItem:(id)item {
//    Reservation *reservation = (Reservation *)item;
//    if (reservation == nil) return;
//    order.reservation = reservation;
//}

- (void) refreshSeatView
{
    SeatView *seatView = [tableWithSeatsView seatViewAtOffset: _selectedSeat];
    [seatView initByGuest: _selectedGuest];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
