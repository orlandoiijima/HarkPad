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

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate> {    
    District *currentDistrict;
    TableButton *dragTableButton;
    bool isVisible;
    UISegmentedControl *districtPicker;
}

- (void) clickTable : (UIControl *) c;
- (IBAction) refreshView;
- (IBAction)gotoDistrict;
- (void) refreshViewWithInfo: (NSMutableArray *)tablesInfo;
- (OrderInfo *) orderInfoForTable: (int)tableId inOrders: (NSMutableArray *)orders;
- (void) setupDistrictPicker;
- (void) newOrderForTable: (Table *) table;
- (void) editOrder: (Order *) order;
- (void) startNextCourse: (Order *)order;
- (void) makeBills: (Order*)order;
- (void) closeOrderView;
- (void) undockTable: (int)tableId;
- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation;
- (void)payOrder: (Order *)order;
- (TableButton *) tableButtonAtPoint: (CGPoint) point;
- (TableButton *) findButton: (Table *) table;
- (NSMutableArray *) dockTableButton: (TableButton *)outerMostTableButton toTableButton: (TableButton*) masterTableButton;
- (bool) TransgenderPopup: (TableButton *) button seat: (int)seat;
- (void) transferOrder: (int)orderId;
- (void) transferOrder: (int)orderId toTable: (int)tableId;
- (TableButton *) buttonForOrder: (int)orderId;

@property (retain) District *currentDistrict;
@property (retain) IBOutlet UISegmentedControl *districtPicker;
@property (retain) IBOutlet UIScrollView *tableMapView;
@property (retain) IBOutlet UIBarButtonItem *buttonRefresh;
@property (retain) IBOutlet UIBarButtonItem *buttonEdit;
@property BOOL isRefreshTimerDisabled;
@property float scaleX;
@property (retain) UIPopoverController *popoverController;
@property (retain) TableButton *dragTableButton;
@property CGPoint dragPosition;
@property CGPoint dragTableOriginalCenter;
@property bool isVisible;
@end
