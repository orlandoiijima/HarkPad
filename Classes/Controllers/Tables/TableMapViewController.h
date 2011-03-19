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

@interface TableMapViewController : UIViewController <UIPopoverControllerDelegate> {    
    District *currentDistrict;
    Map* map;
}

- (void) clickTable : (UIControl *) c;
- (IBAction) refreshTableButtons;
- (OrderInfo *) orderInfoForTable: (int)tableId inOrders: (NSMutableArray *)orders;
- (void) setupDistrictPicker;
- (IBAction) setupDistrictMap;
//- (IBAction) showReservations;
//- (IBAction) gotoChefControlCenter;
- (void) newOrderForTable: (Table *) table;
- (void) editOrder: (Order *) order;
- (void) startNextCourse: (Order *)order;
- (void) makeBills: (Order*)order;
- (void) closeOrderView;
- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation;
- (void)payOrder: (Order *)order;
- (CGRect) rotateRect: (CGRect) rect;


@property (retain) Map* map;
@property (retain) District *currentDistrict;
@property (retain) IBOutlet UISegmentedControl *districtPicker;
@property (retain) IBOutlet UIScrollView *tableMapView;
@property (retain) IBOutlet UIButton *buttonRefresh;
@property BOOL isRefreshTimerDisabled;
@end
