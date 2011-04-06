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
@property (retain) IBOutlet UILabel *count1800;
@property (retain) IBOutlet UILabel *count1830;
@property (retain) IBOutlet UILabel *count1900;
@property (retain) IBOutlet UILabel *count1930;
@property (retain) IBOutlet UILabel *count2000;
@property (retain) IBOutlet UILabel *count2030;
@property (retain) IBOutlet UILabel *countTotal;

- (void) refreshTable;
- (NSString *) keyForSection:(int)section;
- (int) countForKey: (NSString *)key;

- (IBAction) add;
- (void) openEditPopup: (Reservation*)reservation;
- (void) closePopup;
- (void) cancelPopup;
- (Reservation *) reservation: (NSIndexPath *) indexPath;

@end
