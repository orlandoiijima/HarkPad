//
//  ReservationsTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "HostController.h"

@interface ReservationsTableViewController : UIViewController <UITableViewDelegate, UIPopoverControllerDelegate, HostController>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
    NSDate *dateToShow;
}

@property (retain) IBOutlet UITableView *table; 
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) NSDate *dateToShow;
@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;
@property (retain) UIPopoverController *popover;
- (void) refreshTable;

- (IBAction) add;
- (void) openEditPopup: (Reservation*)reservation;
- (void) closePopup;
- (void) cancelPopup;
- (Reservation *) reservation: (NSIndexPath *) indexPath;

@end
