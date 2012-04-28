//
//  ZoomedTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "Order.h"
#import "Guest.h"
#import "TableWithSeatsView.h"
#import "ReservationDataSource.h"
#import "TableOverlayDashboard.h"
#import "Service.h"
#import "ToggleButton.h"
#import "GuestProperties.h"
#import "SelectItemDelegate.h"

@interface ZoomedTableViewController : UIViewController <SelectItemDelegate, TablePopupDelegate>

@property (retain) Order *order;
@property (retain) Guest *selectedGuest;
@property (nonatomic) int selectedSeat;
@property (retain) TableWithSeatsView *tableWithSeatsView;
@property (retain) SeatView *dragSeatView;
@property (nonatomic) CGPoint dragPosition;
@property (nonatomic) CGRect dragOriginalFrame;
@property (retain) ReservationDataSource *reservationDataSource;
@property (retain, nonatomic) TableOverlayDashboard *tableViewDashboard;
@property (retain) id<TablePopupDelegate> delegate;
@property int saveSelectedSeat;

- (void) refreshSeatView;
+ (ZoomedTableViewController *) controllerWithTableView:(TableWithSeatsView *) tableWithSeatsView delegate:(id)delegate;
-(void) getOpenOrderByTableCallback: (ServiceResult *)serviceResult;
- (void) endZoom;

@end
