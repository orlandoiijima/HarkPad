//
//  TableMapViewController.h
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map.h"
#import "OrderInfo.h"
#import "Order.h"
#import "Reservation.h"
#import "PaymentViewController.h"
#import "MBProgressHUD.h"
#import "TablePopupDelegate.h"
#import "TableView.h"
#import "TableOverlaySimple.h"
#import "TableOverlayDashboard.h"

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate, PaymentDelegate, TablePopupDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    TableView *dragTableView;
    TableView *targetTableView;
    bool isVisible;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    UIView *currentDistrictView;
    BOOL isRefreshTimerDisabled;
    UIBarButtonItem *buttonRefresh;
    CGPoint dragPosition;
    CGPoint dragTableOriginalCenter;
    UIPopoverController *popoverController;
    float scaleX;
}

- (void) refreshView;
- (void) refreshViewWithInfo: (NSMutableArray *)tablesInfo;
- (void) editOrder: (Order *) order;
- (void) makeBillForOrder: (Order*)order;
- (void) undockTable: (int)tableId;
- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation;
- (void)getPaymentForOrder: (Order *)order;
- (TableView *) tableViewAtPoint: (CGPoint) point;
- (NSMutableArray *) dockTableView: (TableView *)outerMostTableView toTableView: (TableView *)masterTableView;
- (void) moveOrderFromTableView: (TableView *) from toTableView: (TableView *) to;

- (void) showActivityIndicator;
- (void)hideActivityIndicator;
- (void) setupToolbar;
- (TableView *) createTable: (TableInfo *)table offset: (CGPoint) offset scale: (CGPoint)scale;
- (void)unzoom;
- (void) revertDrag;
- (UIView *)viewForDistrictOffset: (int)offset;

@property (retain) UIScrollView *scrollView;
@property (retain) UIPageControl *pageControl;
@property (retain) UIView *currentDistrictView;
@property (retain) UIBarButtonItem *buttonRefresh;
@property (retain) TableView *zoomedTableView;
@property (retain) NSMutableArray *pages;
@property int currentDistrictOffset;
@property District *currentDistrict;
@property CGPoint zoomScale;
@property CGPoint zoomOffset;
@end
