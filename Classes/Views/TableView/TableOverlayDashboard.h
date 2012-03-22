//
//  TableViewDashboard.h
//  HarkPad
//
//  Created by Willem Bison on 02/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableView.h"
#include "CourseGuestTableView.h"
#include "ReservationDataSource.h"
#include "GuestProperties.h"

#import "TableActionsView.h"
#import "SelectReservationView.h"
#import "TableOverlayInfo.h"

@interface TableOverlayDashboard : UIView <UIScrollViewDelegate>

@property (retain) UIPageControl *pageControl;
@property (retain) SelectReservationView *reservationsTableView;
@property (retain) TableActionsView *actionsView;
@property (retain) TableOverlayInfo *infoView;
@property (retain) UIScrollView *scrollTableView;
@property (retain) GuestProperties *guestProperties;
@property (retain) CourseGuestTableView *courseInfo;
@property (retain) id<TablePopupDelegate> delegate;
@property (retain) Order *order;

- (id)initWithFrame:(CGRect)frame tableView: (TableView *)tableView delegate: (id<TablePopupDelegate>) delegate;
- (void) scrollToView: (UIView *)view;
- (UIView *)viewOnPage: (int)pageControl;

@end
