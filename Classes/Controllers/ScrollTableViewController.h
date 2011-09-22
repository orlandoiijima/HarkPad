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
#import "PopupHost.h"

@interface ScrollTableViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, PopupHost, UISearchBarDelegate> {
    UIScrollView *scrollView;
    ReservationDayView *dayView1;
    ReservationDayView *dayView2;
    NSMutableDictionary *dataSources;
    NSDate *originalStartsOn;
    UIPopoverController *popover;
    UISegmentedControl *segmentShow;
    UISlider *slider;
    UIBarButtonItem *buttonAdd;
    UIBarButtonItem *buttonEdit;
    UIBarButtonItem *buttonPhone;
    UIToolbar *toolbar;
    UIBarButtonItem *buttonWalkin;
}

@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain,atomic) ReservationDayView *currentDayView;
@property (retain) ReservationDayView *dayView1;
@property (retain) ReservationDayView *dayView2;
@property (retain) NSMutableDictionary *dataSources;
@property (retain) NSDate *originalStartsOn;
@property (retain) UIPopoverController *popover;
@property (retain) IBOutlet UISlider *slider;
@property (retain) IBOutlet UILabel *searchHeader;
@property (retain) IBOutlet UISegmentedControl *segmentShow;
@property (retain) IBOutlet UIBarButtonItem *buttonEdit;
@property (retain) IBOutlet UIBarButtonItem *buttonAdd;
@property (retain) IBOutlet UIBarButtonItem *buttonWalkin;
@property (retain) IBOutlet UIBarButtonItem *buttonSearch;
@property (retain) IBOutlet UIBarButtonItem *buttonPhone;
@property (retain) IBOutlet UISearchBar *searchBar;
@property (retain) IBOutlet UIToolbar *toolbar;
@property BOOL isInSearchMode;
@property (retain) NSDate *saveDate;
//@property CGRect saveFrame;
//
//- (void) setupScrolledInPage: (int)page;
- (NSDate *)pageToDate: (int)page;
- (NSString *) dateToKey: (NSDate *)date;
- (void) gotoDayoffset: (int)page;
- (void) setupDayView: (ReservationDayView *)dayView page: (int)page;

- (void) startSearchForText: (NSString *) query;
- (void) searchReservationsCallback: (NSMutableArray *)reservations;
- (IBAction) endSearchMode;

- (IBAction) add;
- (IBAction) addWalkin;
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
