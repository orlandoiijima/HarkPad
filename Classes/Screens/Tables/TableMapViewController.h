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
#import "TableOverlayDashboard.h"

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate, PaymentDelegate, TablePopupDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    District *currentDistrict;
    TableView *dragTableView;
    TableView *targetTableView;
    bool isVisible;
    UISegmentedControl *districtPicker;
    UIView *currentDistrictView;
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
- (void) makeBillForOrder: (Order*)order;
- (void) undockTable: (int)tableId;
- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation;
- (void)getPaymentForOrder: (Order *)order;
- (TableView *) tableViewAtPoint: (CGPoint) point;
- (NSMutableArray *) dockTableView: (TableView *)outerMostTableView toTableView: (TableView *)masterTableView;
//- (void) transferOrder: (int)orderId;
- (void) transferOrder: (int)orderId toTable: (int)tableId;
//- (TableButton *) buttonForOrder: (int)orderId;
- (void) showActivityIndicator;
- (void)hideActivityIndicator;
- (void) setupToolbar;
- (TableView *) createTable: (TableInfo *)table offset: (CGPoint) offset scale: (CGPoint)scale;
- (void)unzoom;

@property (retain) UISegmentedControl *districtPicker;
@property (retain) UIView *currentDistrictView;
@property (retain) UIBarButtonItem *buttonRefresh;
@property (retain) UIPopoverController *popoverController;
@property (retain) TableView *zoomedTableView;
@property (retain) TableOverlayDashboard *tableViewDashboard;
@property (retain) NSMutableArray *pages;
@property int currentDistrictOffset;
@property CGFloat zoomScale;
@property CGPoint zoomOffset;
@end
