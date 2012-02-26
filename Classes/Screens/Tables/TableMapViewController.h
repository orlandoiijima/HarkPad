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
#import "TableButton.h"
#import "PaymentViewController.h"
#import "MBProgressHUD.h"
#import "TablePopupDelegate.h"
#import "TableView.h"
#import "TableOverlaySimple.h"
#import "TableViewDashboard.h"

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate, PaymentDelegate, TablePopupDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    District *currentDistrict;
    TableButton *dragTableButton;
    bool isVisible;
    UISegmentedControl *districtPicker;
    UIView *tableMapView;
    BOOL isRefreshTimerDisabled;
    UIBarButtonItem *buttonEdit;
    UIBarButtonItem *buttonRefresh;
    CGPoint dragPosition;
    CGPoint dragTableOriginalCenter;
    UIPopoverController *popoverController;
    float scaleX;
}

- (IBAction) refreshView;
- (IBAction)gotoDistrict;
- (void) refreshViewWithInfo: (NSMutableArray *)tablesInfo;
- (void) editOrder: (Order *) order;
- (void) startNextCourse: (Order *)order;
- (void) makeBillForOrder: (Order*)order;
- (void) undockTable: (int)tableId;
- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation;
- (void)getPaymentForOrder: (Order *)order;
- (TableButton *) tableButtonAtPoint: (CGPoint) point;
- (NSMutableArray *) dockTableButton: (TableButton *)outerMostTableButton toTableButton: (TableButton*) masterTableButton;
- (void) transferOrder: (int)orderId;
- (void) transferOrder: (int)orderId toTable: (int)tableId;
- (TableButton *) buttonForOrder: (int)orderId;
- (void) showActivityIndicator;
- (void)hideActivityIndicator;
- (void) setupToolbar;
- (TableView *) createTable: (TableInfo *)table offset: (CGPoint) offset scale: (CGPoint)scale;
- (void) setupZoomedView;
- (void) clearZoomedView;
- (void)unzoom;

@property (retain) UISegmentedControl *districtPicker;
@property (retain) UIView *tableMapView;
@property (retain) UIBarButtonItem *buttonRefresh;
@property (retain) UIPopoverController *popoverController;
@property (retain) TableView *zoomedTableView;
@property (retain) TableViewDashboard *tableViewDashboard;
@property CGFloat zoomScale;
@property CGPoint zoomOffset;
@end
