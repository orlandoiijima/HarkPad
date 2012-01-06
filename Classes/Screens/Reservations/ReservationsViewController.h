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
#import "../../Controllers/ReservationEditViewController.h"
#import "CalendarMonthView.h"
#import "GTMHTTPFetcher.h"
#import "ServiceResult.h"
#import "NSDate-Utilities.h"
#import "PopupHost.h"
#import "ToggleButton.h"

@interface ReservationsViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, PopupHost, UISearchBarDelegate, CalendarViewDelegate> {
    ReservationDayView *dayView;
    UIScrollView *scrollView;
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

@property (retain) UIScrollView *scrollView;
@property (retain) NSMutableArray *calendarViews;
@property (retain) IBOutlet ReservationDayView *dayView;
@property (retain) NSMutableDictionary *dataSources;
@property (retain) NSDate *originalStartsOn;
@property (retain) IBOutlet UILabel *searchHeader;
@property (retain) IBOutlet UISegmentedControl *segmentShow;
@property (retain) IBOutlet UIBarButtonItem *buttonEdit;
@property (retain) IBOutlet UIBarButtonItem *buttonAdd;
@property (retain) IBOutlet UIBarButtonItem *buttonWalkin;
@property (retain) IBOutlet UIBarButtonItem *buttonSearch;
@property (retain) IBOutlet UISearchBar *searchBar;
@property (retain) IBOutlet UIToolbar *toolbar;
@property BOOL isInSearchMode;
@property BOOL isInCalendarMode;
@property (retain) NSDate *saveDate;

- (NSString *) dateToKey: (NSDate *)date;
- (void) gotoDate: (NSDate *)date;
- (CalendarMonthView *)calendarViewForDate: (NSDate *)date;

- (void) startSearchForText: (NSString *) query;
- (void) searchReservationsCallback: (NSMutableArray *)reservations;
- (IBAction) endSearchMode;

- (IBAction) add;
- (IBAction) addWalkin;
- (IBAction) editMode;
- (void) edit;
- (IBAction) showMode;
- (void) openEditPopup: (Reservation*)reservation;
- (void) closePopup;
- (void) cancelPopup;
- (void) toggleShowCalendar;

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;

- (void)refreshCalendar;
@end
