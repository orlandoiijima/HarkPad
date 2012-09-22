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
#import "TableWithSeatsView.h"
#import "TableOverlaySimple.h"
#import "TableOverlayDashboard.h"

@class ZoomedTableViewController;

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate, PaymentDelegate, TableCommandsDelegate, TablePopupDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    TableWithSeatsView *dragTableView;
    TableWithSeatsView *targetTableView;
    bool isVisible;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    UIView *currentDistrictView;
    BOOL isRefreshTimerDisabled;
    UIBarButtonItem *buttonRefresh;
    CGPoint dragPosition;
    CGPoint dragTableOriginalCenter;
    UIPopoverController *popoverController;
    float mapScaleX;
    CGPoint mapOffset;
}

- (void) refreshView;
- (void) editOrder: (Order *) order;
- (void) updateOrder: (Order *) order;
- (void) makeBillForOrder: (Order*)order;
- (void) undockTable: (NSString *)tableId;
- (void)getPaymentForOrder: (Order *)order;
- (TableWithSeatsView *) tableViewAtPoint: (CGPoint) point;
- (void) dockTableView: (TableWithSeatsView *)outerMostTableView toTableView: (TableWithSeatsView *)masterTableView;
- (void) moveOrderFromTableView: (TableWithSeatsView *) from toTableView: (TableWithSeatsView *) to;

- (void) setupToolbar;
- (TableWithSeatsView *) createTable: (TableInfo *)table offset: (CGPoint) offset scale: (CGPoint)scale;
- (void)unzoom;
- (void) zoomToTable:(TableWithSeatsView *)tableView;
- (void) revertDrag;
- (UIView *)viewForDistrictOffset: (int)offset;

@property (retain) UIScrollView *scrollView;
@property (retain) UIPageControl *pageControl;
@property (retain) UIView *currentDistrictView;
@property (retain) UIBarButtonItem *buttonRefresh;
@property (retain) TableWithSeatsView *zoomedTableView;
@property (retain) NSMutableArray *pages;
@property int currentDistrictOffset;
@property District *currentDistrict;
@property CGPoint zoomScale;
@property CGPoint zoomOffset;
@property NSString *caption;
@property (retain) NSDate *switchedDistrictWhileDragging;
@property(nonatomic, strong) ZoomedTableViewController *zoomedTableController;
@end
