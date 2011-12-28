//
//  ReservationListController.h
//  HarkPad
//
//  Created by Willem Bison on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReservationDataSource.h"

@protocol SelectItemDelegate;

@interface ReservationListController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain) ReservationDataSource *dataSource;
@property (retain) id<SelectItemDelegate> delegate;

@end