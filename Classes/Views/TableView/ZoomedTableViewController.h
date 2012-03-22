//
//  ZoomedTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "Order.h"
#import "Guest.h"
#import "TableView.h"
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
@property (retain) TableView *tableView;
@property (retain) ReservationDataSource *reservationDataSource;
@property (retain, nonatomic) TableOverlayDashboard *tableViewDashboard;
@property (retain) id<TablePopupDelegate> delegate;

- (void) refreshSeatView;

@end
