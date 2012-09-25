//
//  ReservationViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "GTMHTTPFetcher.h"
#import "PopupHost.h"

@protocol ItemPropertiesDelegate;

@interface ReservationEditViewController : UIViewController {
    Reservation *reservation;
    UITextView *notesView;
    UITextField *nameView;
    UITextField *emailView;
    UITextField *phoneView;
    UIDatePicker *datePicker;
    UITextField *countView;
    UISegmentedControl *languageView;
    NSMutableArray *languages;
    id<ItemPropertiesDelegate> delegate;
}

@property (retain, nonatomic) Reservation *reservation;
@property (retain) IBOutlet UIDatePicker *datePicker;
@property (retain) IBOutlet UITextView *notesView;
@property (retain) IBOutlet UITextField *nameView;
@property (retain) IBOutlet UITextField *emailView;
@property (retain) IBOutlet UITextField *phoneView;
@property (retain) IBOutlet UITextField *countView;
@property (retain) IBOutlet UISegmentedControl *languageView;
@property (nonatomic, retain) id<ItemPropertiesDelegate> delegate;
@property (retain) NSMutableArray *languages;
+ (ReservationEditViewController *) initWithReservation: (Reservation *)reservation delegate: (id<ItemPropertiesDelegate>)delegate;

- (IBAction) save;
- (IBAction) cancel;
- (void) initLanguageView: (NSString *)language;

@end
