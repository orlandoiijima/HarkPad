//
//  ScrollTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 01-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReservationDayView.h"
#import "ReservationDataSource.h"
#import "ReservationViewController.h"
#import "GTMHTTPFetcher.h"
#import "ServiceResult.h"
#import "NSDate-Utilities.h"

@interface ScrollTableViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate> {
    UIScrollView *scrollView;
    ReservationDayView *currentPage;
    ReservationDayView *nextPage;
}

@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) ReservationDayView *currentPage;
@property (retain) ReservationDayView *nextPage;
@property (retain) NSMutableDictionary *dataSources;
@property (retain) NSDate *originalStartsOn;
@property (retain) UIPopoverController *popover;
@property (retain) IBOutlet UISlider *slider;
@property (retain) IBOutlet UISegmentedControl *segmentShow;
@property (retain) IBOutlet UIBarButtonItem *buttonEdit;
@property (retain) IBOutlet UIBarButtonItem *buttonAdd;
@property (retain) IBOutlet UIBarButtonItem *buttonPhone;
@property (retain) IBOutlet UIToolbar *toolbar;

- (void) setupScrolledInPage: (int)page;
- (NSDate *)pageToDate: (int)page;
- (NSString *) dateToKey: (NSDate *)date;
- (void) gotoDayoffset: (int)page;

- (IBAction) add;
- (IBAction) call;
- (IBAction) editMode;
- (void) edit;
- (IBAction) showMode;
- (void) openEditPopup: (Reservation*)reservation;
- (void) closePopup;
- (void) cancelPopup;

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;

- (IBAction) sliderUpdate;

@end
