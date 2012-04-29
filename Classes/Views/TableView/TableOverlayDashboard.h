//
//  TableViewDashboard.h
//  HarkPad
//
//  Created by Willem Bison on 02/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableWithSeatsView.h"
#include "ReservationDataSource.h"
#include "GuestProperties.h"

#import "TableActionsView.h"
#import "SelectReservationView.h"
#import "TableOverlayInfo.h"

@interface TableOverlayDashboard : UIView <UIScrollViewDelegate>

@property (retain) UIView *pageControl;
@property (retain) SelectReservationView *reservationsTableView;
@property (retain) TableActionsView *actionsView;
@property (retain) TableOverlayInfo *infoView;
@property (retain) UIView *contentView;
@property (retain) UIView *currentView;
@property (retain) GuestProperties *guestProperties;
@property (retain) id<TablePopupDelegate> delegate;
@property (retain) Order *order;
@property (retain) NSMutableArray *buttonViews;

- (id)initWithFrame:(CGRect)frame tableView: (TableWithSeatsView *)tableView order:(Order *)anOrder delegate: (id<TablePopupDelegate>) aDelegate;
- (UIButton *)createBarButtonWithFrame: (CGRect) frame image:(UIImage *)image tag: (int)tag;
-(void) gotoView: (UIView *)view;

@end
