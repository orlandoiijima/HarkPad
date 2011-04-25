//
//  ReservationViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "ReservationsTableViewController.h"
#import "GTMHTTPFetcher.h"

@interface ReservationViewController : UIViewController {
    Reservation *reservation;
    UITextView *notesView;
    UITextField *nameView;
    UITextField *emailView;
    UITextField *phoneView;
    UIDatePicker *datePicker;
    UISegmentedControl *countView;
    UISegmentedControl *languageView;
    
}

@property (retain) Reservation *reservation;
@property (retain) IBOutlet UIDatePicker *datePicker;
@property (retain) IBOutlet UITextView *notesView;
@property (retain) IBOutlet UITextField *nameView;
@property (retain) IBOutlet UITextField *emailView;
@property (retain) IBOutlet UITextField *phoneView;
@property (retain) IBOutlet UISegmentedControl *countView;
@property (retain) IBOutlet UISegmentedControl *languageView;
@property (retain) ReservationsTableViewController *hostController;
@property (retain) NSMutableArray *languages;
+ (ReservationViewController *) initWithReservation: (Reservation *)reservation;

- (IBAction) save;
- (IBAction) cancel;
- (void) initLanguageView: (NSString *)language;

@end
