//
//  SelectReservationView.h
//  HarkPad
//
//  Created by Willem Bison on 02/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class ReservationDataSource;
@class Reservation;

@protocol SelectItemDelegate;

@interface SelectReservationView : UIView <UITableViewDelegate>

@property (nonatomic) ReservationDataSource *dataSource;
@property (retain) UITableView *tableView;
@property (retain) UILabel *label;
@property (retain) UILabel *emptyLabel;
@property (retain) id<SelectItemDelegate> delegate;
@property (retain) Reservation *selectedReservation;

- (id)initWithFrame:(CGRect)frame delegate: (id<SelectItemDelegate>) delegate;

@end
