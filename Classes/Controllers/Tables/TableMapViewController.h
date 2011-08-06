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
    UIScrollView *tableMapView;
    BOOL isRefreshTimerDisabled;
    UIBarButtonItem *buttonEdit;
    UIBarButtonItem *buttonRefresh;
    CGPoint dragPosition;
    CGPoint dragTableOriginalCenter;
    UIPopoverController *popoverController;
    float scaleX;
}

- (void) clickTable : (UIControl *) c;
- (IBAction) refreshView;
- (IBAction)gotoDistrict;
- (void) refreshViewWithInfo: (NSMutableArray *)tablesInfo;
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
- (NSMutableArray *) dockTableButton: (TableButton *)outerMostTableButton toTableButton: (TableButton*) masterTableButton;
- (bool) TransgenderPopup: (TableButton *) button seat: (int)seat;
- (void) transferOrder: (int)orderId;
- (void) transferOrder: (int)orderId toTable: (int)tableId;
- (TableButton *) buttonForOrder: (int)orderId;

@property (retain) IBOutlet UISegmentedControl *districtPicker;
@property (retain) IBOutlet UIScrollView *tableMapView;
@property (retain) IBOutlet UIBarButtonItem *buttonRefresh;
@property (retain) UIPopoverController *popoverController;
@end
