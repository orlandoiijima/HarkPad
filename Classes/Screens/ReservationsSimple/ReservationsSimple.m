//
//  ReservationsSimple.m
//  HarkPad
//
//  Created by Willem Bison on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReservationsSimple.h"
#import "ReservationDayView.h"
#import "Service.h"
#import "NSDate-Utilities.h"
#import "CalendarViewController.h"

@implementation ReservationsSimple

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

@synthesize dayView;

- (void)loadView
{
    self.view = [[ReservationDayView alloc] initWithFrame:CGRectMake(0, 0, 400, 300) delegate:self];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIBarButtonItem *calendarButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"calendarsmall.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoCalendar)];
    UIBarButtonItem *phoneButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"phonesmall.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(call)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
        calendarButton,
        phoneButton,
        nil];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                [NSArray arrayWithObjects:
                                                    [UIImage imageNamed:@"leftarrow.png"],
                                                    [UIImage imageNamed:@"rightarrow.png"],
                                                 nil]];
    [segmentedControl addTarget:self action:@selector(nextDay:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 80, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.momentary = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    [self gotoDate:[NSDate date]];
}

- (void)nextDay: (id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    int delta = segmentedControl.selectedSegmentIndex == 0 ? -1 : 1;
    [self gotoDate: [self.dayView.date dateByAddingDays: delta]];
}

- (void) gotoCalendar
{
    CalendarViewController *calendarController = [[CalendarViewController alloc] init];
    calendarController.delegate = self;
    [calendarController gotoDate: self.dayView.date];
    [self.navigationController pushViewController:calendarController animated:YES];
}

- (void) call
{
    Reservation *reservation = [self.dayView selectedReservation];
    if(reservation == nil || reservation.phone == nil || reservation.phone == @"") return;
    NSString *phoneNumber = [@"tel://" stringByAppendingString:reservation.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)didSelectItem:(id)item {
    [self gotoDate:(NSDate *)item];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (ReservationDayView *)dayView
{
    return (ReservationDayView *)self.view;
}

- (void) gotoDate: (NSDate *)date
{
    self.dayView.date = date;
    [[Service getInstance] getReservations: self.dayView.date delegate:self callback:@selector(getReservationsCallback:onDate:)];
}

- (void) getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date
{
    NSMutableArray *reservations = serviceResult.data;
    Reservation *selectedReservation = self.dayView.selectedReservation;
    ReservationDataSource *dataSource = [ReservationDataSource dataSourceWithDate:date includePlacedReservations: YES withReservations:reservations];
    if([self.dayView.date isEqualToDateIgnoringTime:date]) {
        self.dayView.dataSource = dataSource;
    }
    if(selectedReservation != nil)
        self.dayView.selectedReservation = selectedReservation;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
