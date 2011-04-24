//
//  ReservationsTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "GTMHTTPFetcher.h"

@interface ReservationsTableViewController : UIViewController <UITableViewDelegate, UIPopoverControllerDelegate>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
    NSDate *dateToShow;
    Reservation *copyReservation;
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
@property (retain) IBOutlet UISegmentedControl *segmentShow; 
@property bool isVisible;
@property (retain) NSDate *originalStartsOn;

- (void) refreshView;
- (void) reloadData;

- (IBAction) add;
- (IBAction) edit;
- (IBAction) showMode;
- (void) openEditPopup: (Reservation*)reservation;
- (void) closePopup;
- (void) cancelPopup;

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;


@end
