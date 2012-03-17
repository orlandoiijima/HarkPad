//
//  CalendarViewController.m
//  HarkPad
//
//  Created by Willem Bison on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarMonthView.h"
#import "NSDate-Utilities.h"

@implementation CalendarViewController

@synthesize delegate;

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

- (CalendarMonthView *)calendarView
{
    return (CalendarMonthView *)self.view;
}

- (void)loadView
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];

    //  frame not set ?!?!?
    CalendarMonthView *calendarView = [[CalendarMonthView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height - 44 - 49 - 20)];
    calendarView.calendarDelegate = self;
    calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    calendarView.startMonth = [[NSDate date] month];
    calendarView.startYear = [[NSDate date] year];
    self.view = calendarView;
}

- (void) gotoDate: (NSDate *)date
{
    self.calendarView.selectedDate = date;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.calendarView.columnWidth = self.calendarView.bounds.size.width / 7;
    [self.calendarView refreshReservations];
    [self.calendarView reloadData];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                [NSArray arrayWithObjects:
                                                    [UIImage imageNamed:@"leftarrow.png"],
                                                    [UIImage imageNamed:@"rightarrow.png"],
                                                 nil]];
    [segmentedControl addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 80, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.momentary = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];

}

- (void)nextMonth: (id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSDate *date;
    if (segmentedControl.selectedSegmentIndex == 0)
        date = [[[self.calendarView firstDateInMonth] dateByAddingDays:-1] dateAtStartOfMonth];
    else
        date = [[self.calendarView lastDateInMonth] dateByAddingDays:1];
    [self gotoDate:date];
}

- (void)calendarView:(CalendarMonthView *)calendarView didTapDate:(NSDate *)date {
    if([self.delegate respondsToSelector:@selector(didSelectItem:)])
        [self.delegate didSelectItem: date];
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
