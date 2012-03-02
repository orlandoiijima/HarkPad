//
//  TablePopupViewController.h
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Table.h"
#import "Order.h"
#import "Service.h"
#import "ReservationDataSource.h"
#import "TableMapViewController.h"

typedef enum buttonState {disabled, enabled,highlighted, special} buttonState;

@interface TablePopupViewController : UIViewController <UITableViewDelegate>{
    Table *table;
    Order *order;
    UITableView *tableReservations;
    UILabel *labelReservations;
    UILabel *labelNextCourse;
    UIButton *buttonGetPayment;
    UIButton *buttonMakeBill;
    UIButton *buttonMakeOrder;
    UIButton *buttonStartCourse;
    UILabel *labelTable;
    UIPopoverController *popoverController;
    UITextView *labelReservationNote;
    UIButton *buttonUndockTable;
    UIButton *buttonTransferOrder;
}

@property (retain) IBOutlet UITableView *tableReservations;
@property (retain) IBOutlet UIButton *buttonMakeOrder;
@property (retain) IBOutlet UIButton *buttonMakeBill;
@property (retain) IBOutlet UIButton *buttonGetPayment;
@property (retain) IBOutlet UIButton *buttonStartCourse;
@property (retain) IBOutlet UIButton *buttonUndockTable;
@property (retain) IBOutlet UIButton *buttonTransferOrder;
@property (retain) IBOutlet UILabel *labelTable;
@property (retain) IBOutlet UILabel *labelReservations;
@property (retain) IBOutlet UITextView *labelReservationNote;


@property (retain) Table *table;
@property (retain) Order *order;

@property (retain) UIPopoverController *popoverController;

@property (retain) ReservationDataSource *reservationDataSource;

- (TableMapViewController *) tableMapController;
- (void) setOptimalSize;
- (void) setButton: (UIButton*) button state: (buttonState)state;

- (IBAction) makeBill;
- (IBAction) getPayment;
- (IBAction) undockTable;
- (IBAction) transferOrder;
- (void) placeReservation: (Reservation*)reservation;
- (void) updateOnOrder;
- (CGSize) getSizeFromBottomItem: (UIView *)view;

@end
