//
//  ScrollTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 01-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationsViewController.h"
#import "Service.h"
#import "CalendarDayCell.h"
#import "ModalAlert.h"
#import "MBProgressHUD.h"
#import "PreviousReservationsViewController.h"
#import "TestFlight.h"
#import "Logger.h"

@implementation ReservationsViewController

@synthesize dayView, dataSources, originalStartsOn, segmentShow, buttonAdd, buttonEdit, toolbar, buttonWalkin, isInSearchMode, searchBar, saveDate, buttonSearch, calendarViews, isInCalendarMode, scrollView, buttonPrevious;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TestFlight passCheckpoint: [[self class] description]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    isInCalendarMode = YES;
    calendarViews = [[NSMutableArray alloc] init];
    int margin = 15;
    int top = (int)toolbar.bounds.size.height + margin;
    int width = (int)(self.view.bounds.size.width - 3*margin) / 2;
    int height = (int)(self.view.bounds.size.height - 3 * margin - top) / 3;
    height = ((height - 40) / 6) * 6 + 40;

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(margin, top, width, 3 * (height + margin))];
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 6 * (height + margin));
 //   self.scrollView.pagingEnabled = YES;

    int y = 0;
    NSDate *date = [[[NSDate date] dateAtStartOfMonth] dateBySubtractingDays:1];
    for(int month = 0; month < 6; month++) {
        CalendarMonthView *view = [CalendarMonthView calendarWithFrame: CGRectMake(0, y, width, height) forDate: date];
        [self.scrollView addSubview:view];
        view.calendarDelegate = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [calendarViews addObject:view];
        [view reloadData];
        y += height + margin;
        date = [[date dateAtEndOfMonth] dateByAddingDays:1];
    }
    [self.scrollView setContentOffset:CGPointMake(0, height +margin) animated:NO];
    [self refreshCalendar];

    CGRect frameDay = CGRectMake(self.view.bounds.size.width/2, top, self.view.bounds.size.width/2, self.view.bounds.size.height - 50);
    self.dayView = [[ReservationDayView alloc] initWithFrame:frameDay delegate:self];
    self.dayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:dayView];

    self.dataSources = [[NSMutableDictionary alloc] init];
    [self gotoDate:[NSDate date]];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGestureRecognizer];

    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];

    [NSTimer scheduledTimerWithTimeInterval:20.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];   
    
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(isInSearchMode)
        [self endSearchMode];
    else
        [self gotoDate: [NSDate date]];
}

- (void)handleSwipeRight:(UITapGestureRecognizer *)swipeGestureRecognizer {
    if (isInCalendarMode)
        return;
    [self toggleShowCalendar];
}

- (void)handleSwipeLeft:(UITapGestureRecognizer *)swipeGestureRecognizer {
    if (isInCalendarMode == false)
        return;
    [self toggleShowCalendar];
}

- (CalendarMonthView *)calendarViewForDate: (NSDate *)date
{
    for(CalendarMonthView *view in calendarViews) {
        if ([view isInView:date]) {
            return view;
        }
    }
    return nil;
}

- (void) refreshView
{
    if(self.dayView == nil) return;
    if(self.dayView.dataSource == nil || self.dayView.dataSource.date == nil) return;
    NSDate *date = self.dayView.dataSource.date;
    [[Service getInstance]
            getReservations: date
                   success:^(ServiceResult *serviceResult) {
                       [self OnSuccessGetReservationsAtDate:date withResult:serviceResult];
                   }
                     error:^(ServiceResult *serviceResult) {
                          [serviceResult displayError];
                   }
    ];
}

- (void) OnSuccessGetReservationsAtDate: (NSDate *)date withResult: (ServiceResult *)serviceResult {
    NSMutableArray *reservations = [[NSMutableArray alloc] init];
    for(NSDictionary *reservationDic in serviceResult.jsonData)
    {
        Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic];
        [reservations addObject:reservation];
    }
    Reservation *selectedReservation = self.dayView.selectedReservation;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    ReservationDataSource *dataSource = [ReservationDataSource dataSourceWithDate:date includePlacedReservations: includeSeated withReservations:reservations];
    NSString *key = [self dateToKey: dataSource.date];
    [dataSources setObject: dataSource forKey:key];
    if([dayView.date isEqualToDateIgnoringTime:date]) {
        dayView.dataSource = dataSource;
        [self updateCalendarWithReservations: reservations forDate: date];
    }
    if(selectedReservation != nil)
        self.dayView.selectedReservation = selectedReservation;
}

- (NSString *) dateToKey: (NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yy"];
    return [format stringFromDate:date];
}

- (void) gotoDate: (NSDate *)date
{
    if(isInSearchMode)
        [self endSearchMode];
    
    dayView.date = date;
    NSString *key = [self dateToKey: dayView.date];
    ReservationDataSource *dataSource = [dataSources objectForKey:key];
    if(dataSource == nil) {
        dataSource = [[ReservationDataSource alloc] init];
        [dataSources setObject: dataSource forKey:key];
        [Logger info:@"start call"];
        [[Service getInstance]
            getReservations: date
                success:^(ServiceResult *serviceResult) {
                    [self OnSuccessGetReservationsAtDate:date withResult:serviceResult];
                }
                error:^(ServiceResult *serviceResult) {
                    [serviceResult displayError];
                }
        ];
    }
    else {
        dayView.dataSource = dataSource;
    }
    
    for(CalendarMonthView *view in calendarViews) {
        if ([view isInView:date])
            view.selectedDate = date;
        else
            view.selectedDate = nil;
    }
}

- (void)calendarView:(CalendarMonthView *)calendarView didTapDate:(NSDate *)date {
    for(CalendarMonthView *view in calendarViews) {
        if (view != calendarView)
            view.selectedDate = nil;
    }
    [self gotoDate:date];
}

- (void) openEditPopup: (Reservation*)reservation
{
    ReservationEditViewController *popup = [ReservationEditViewController initWithReservation: reservation delegate:self];
    popover = [[UIPopoverController alloc] initWithContentViewController: popup];
    popover.delegate = self;
    
    UIBarButtonItem *button;
    if (reservation.id != 0) {
        self.originalStartsOn = [reservation.startsOn copyWithZone:nil];
        button = buttonEdit;
    }
    else {
        self.originalStartsOn = nil;
        if (reservation.type == ReservationTypeWalkin)
            button = buttonWalkin;
    else
            button = buttonAdd;
    }
    [popover presentPopoverFromBarButtonItem: button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didModifyItem:(id)item {
    [self closePopup];
}

- (void)didSaveItem:(id)item {
    [MBProgressHUD showSucceededAddedTo:self.view withText: NSLocalizedString(@"Reservation stored", nil)];
    [self closePopup];
    return;
}

- (void)didCancelItem:(id)item {
    [self cancelPopup];
}

- (void) editMode
{
    if(self.dayView == nil || self.dayView.table == nil) return;
    if([self.dayView.table isEditing])
        [self.dayView.table setEditing:NO];
    else
        [self.dayView.table setEditing:YES];
}

- (void) edit
{
    Reservation *reservation = [self.dayView selectedReservation];
    if(reservation == nil || reservation.id == 0) return;
    [self openEditPopup:reservation];
}	

- (void) call
{
    Reservation *reservation = [self.dayView selectedReservation];
    if(reservation == nil || reservation.phone == nil || reservation.phone == @"") return;
    NSString *phoneNumber = [@"tel://" stringByAppendingString:reservation.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}	

- (void) showMode
{
    ReservationDataSource *dataSource = self.dayView.dataSource;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    if(dataSource.includePlacedReservations == includeSeated)
        return;
    [dataSource tableView: self.dayView.table includeSeated: includeSeated];
}			

- (void) closePopup
{
    ReservationEditViewController *popup = (ReservationEditViewController *) popover.contentViewController;
    Reservation *reservation = popup.reservation;
    [popover dismissPopoverAnimated:YES];
    NSString *key = [self dateToKey:reservation.startsOn];
    ReservationDayView *dayViewNew = nil;
    ReservationDataSource *dataSourceNew = nil;
    if(isInSearchMode)
    {
        dayViewNew = self.dayView;
        dataSourceNew = dayViewNew.dataSource;
    }
    else
    {        
        if([dayView.date isEqualToDateIgnoringTime:reservation.startsOn])
            dayViewNew = dayView;
        dataSourceNew = [dataSources objectForKey:key];
    }

    if(originalStartsOn == nil)
    {
        //  New reservation
        [dataSourceNew addReservation:reservation fromTableView: dayViewNew.table];
    }
    else
    {
        if([reservation.startsOn isEqualToDate: originalStartsOn]) {
            [self.dayView.dataSource updateReservation:reservation fromTableView:self.dayView.table];
        }
        else {
            //  Edit, new day
            NSDate *startsOn = reservation.startsOn;
            reservation.startsOn = originalStartsOn;
            [self.dayView.dataSource deleteReservation:reservation fromTableView: self.dayView.table];

            reservation.startsOn = startsOn;
            [dataSourceNew addReservation:reservation fromTableView: dayViewNew.table];
        }
    }
    [self.dayView refreshTotals];
    [self.dayView.table setEditing:NO];
//    [self refreshCalendar];
}
    
- (void) cancelPopup
{
    [popover dismissPopoverAnimated:YES];
}

- (IBAction) add
{
    Reservation *reservation = [[Reservation alloc] init];
    NSDate *date = self.dayView.dataSource.date;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSUInteger) -1 fromDate:date];
    [comps setHour:20];
    [comps setMinute:0];
    reservation.startsOn = [[NSCalendar currentCalendar] dateFromComponents:comps];
    if([reservation.startsOn compare:[NSDate date]] == NSOrderedAscending)
    {
        [comps setDay:[comps day] + 1];
        reservation.startsOn = [[NSCalendar currentCalendar] dateFromComponents:comps];
    }
    [self openEditPopup:reservation];
}

- (IBAction) addWalkin
{
    Reservation *reservation = [[Reservation alloc] init];
    reservation.type = ReservationTypeWalkin;
    self.originalStartsOn = nil;
    [self openEditPopup:reservation];
}

- (void) toggleShowCalendar
{
    isInCalendarMode = !isInCalendarMode;
    [UIView animateWithDuration:0.2f animations: ^{
        if(isInCalendarMode)
            self.scrollView.center = CGPointMake(15 + self.scrollView.bounds.size.width / 2, self.scrollView.center.y);
        else
            self.scrollView.center = CGPointMake( - self.scrollView.bounds.size.width / 2, self.scrollView.center.y);
        if(isInCalendarMode)
            self.dayView.frame = CGRectMake(self.view.bounds.size.width/2, self.dayView.frame.origin.y, self.view.bounds.size.width/2, self.view.bounds.size.height - 50);
        else
            self.dayView.frame = CGRectMake(0, self.dayView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - 50);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    [bar endEditing:YES];
    [self startSearchForText: bar.text];
}

- (void) endSearchMode
{
    searchBar.text = @"";
    isInSearchMode = NO;
    [dayView endSearchMode];
    NSString *key = [self dateToKey: saveDate];
    self.dayView.dataSource = [dataSources objectForKey:key];
}

- (void) startSearchForText: (NSString *) query
{
    isInSearchMode = YES;

    [dayView startSearchModeWithQuery:query];
    saveDate = dayView.date;
    [[Service getInstance] searchReservationsForText: query success:^(ServiceResult *serviceResult) {
        NSMutableArray *reservations = serviceResult.data;
        [dayView setSearchCaptionLabelText: [NSString stringWithFormat: NSLocalizedString(@"Reservations found with '%@':", nil), searchBar.text]];

        ReservationDataSource *dataSource = [ReservationDataSource dataSourceWithDate: nil includePlacedReservations: YES withReservations:reservations];
        if(self.dayView != nil) {
            self.dayView.dataSource = dataSource;
        }
    }
    error: ^(ServiceResult *serviceResult) {
        [serviceResult displayError];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.dayView.table isEditing])
        [self edit];
}

- (IBAction) showPreviousReservations
{
    Reservation *reservation = [self.dayView selectedReservation];
    if (reservation == nil)
        return;
    PreviousReservationsViewController *controller = [PreviousReservationsViewController controllerWithReservationId: reservation.id];
    popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    popover.delegate = self;
    [popover setPopoverContentSize:CGSizeMake(600, 400)];
    CGRect rect = [self.dayView.table rectForRowAtIndexPath:[self.dayView.table indexPathForSelectedRow]];
    [popover presentPopoverFromRect:rect inView:self.dayView.table permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)refreshCalendar
{
    for(CalendarMonthView *calendarView in self.calendarViews)
        [calendarView refreshReservations];
}

- (void) updateCalendarWithReservations: (NSMutableArray *)reservations forDate: (NSDate *)date
{
    for(CalendarMonthView *view in calendarViews) {
        if ([view isInView:date]) {
            CalendarDayCell *cell = [view cellForDate:date];
            if (cell != nil) {
                DayReservationsInfo *info = [[DayReservationsInfo alloc] init];
                info.dinnerStatus = cell.dinnerStatus;
                info.lunchStatus = cell.lunchStatus;
                for(Reservation *reservation in reservations) {
                    if (reservation.startsOn.hour > 16)
                        info.dinnerCount += reservation.countGuests;
                    else
                        info.lunchCount += reservation.countGuests;
                }
 //               [cellRuns setInfo:info];
            }
        }
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


@end
