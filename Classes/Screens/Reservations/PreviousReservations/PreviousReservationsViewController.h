//
//  PreviousReservationsViewController.h
//  HarkPad
//
//  Created by Willem Bison on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class ServiceResult;
@class ReservationDataSource;
@class OrderDataSource;

@interface PreviousReservationsViewController : UIViewController <UITableViewDelegate>

@property (retain) UITableView *reservationsTableView;
@property (retain) UITableView *orderTableView;
@property (retain) UILabel *headerLabel;
@property int reservationId;

@property(nonatomic, strong) ReservationDataSource *reservationDataSource;

@property(nonatomic, strong) OrderDataSource *orderDataSource;

- (void) getReservationsCallback: (ServiceResult *)serviceResult;
+ (PreviousReservationsViewController *) controllerWithReservationId: (int) reservationId;

@end
