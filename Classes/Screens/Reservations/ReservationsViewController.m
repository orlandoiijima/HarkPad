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
#import "DayReservationsInfo.h"
#import "ModalAlert.h"
#import "MBProgressHUD.h"

@implementation ReservationsViewController

@synthesize dayView, dataSources, originalStartsOn, segmentShow, buttonAdd, buttonEdit, toolbar, buttonWalkin, isInSearchMode, searchBar, saveDate, buttonSearch, searchHeader, calendarViews, isInCalendarMode, scrollView;

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
    [[Service getInstance] getReservations: self.dayView.dataSource.date delegate:self callback:@selector(getReservationsCallback:onDate:)];
}

- (void) getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date
{
    NSMutableArray *reservations = serviceResult.data;
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
        [[Service getInstance] getReservations: dayView.date delegate:self callback:@selector(getReservationsCallback:onDate:)];
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
    ReservationEditViewController *popup = [ReservationEditViewController initWithReservation: reservation];
    popover = [[UIPopoverController alloc] initWithContentViewController: popup];
    popup.hostController = self;
    popover.delegate = self;
    
    UIBarButtonItem *button;
    if (reservation.id != 0)
        button = buttonEdit;
    else
        if (reservation.type == Walkin)
            button = buttonWalkin;
    else
            button = buttonAdd;
    [popover presentPopoverFromBarButtonItem: button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Reservation *reservation = (Reservation *)fetcher.userData;
    if(reservation == nil) return;
    
    ServiceResult *serviceResult = [ServiceResult resultFromData:data error:error];
    if(serviceResult.id != -1) {
        reservation.id = serviceResult.id;
        [MBProgressHUD showSucceededAddedTo:self.view withText: NSLocalizedString(@"Reservation stored", nil)];
    }
    else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
    }
    return;
}

- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Reservation *reservation = [self.dayView selectedReservation];
    if(reservation == nil) return;
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
    self.originalStartsOn = [reservation.startsOn copyWithZone:nil];
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

    if(reservation.id == 0)
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
    reservation.type = Walkin;
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
    searchHeader.hidden = YES;
    [dayView showHeader];
    NSString *key = [self dateToKey: saveDate];
    self.dayView.dataSource = [dataSources objectForKey:key];
}

- (void) startSearchForText: (NSString *) query
{
    isInSearchMode = YES;
    searchHeader.hidden = NO;
    
    [dayView hideHeader];
    saveDate = dayView.date;
    searchHeader.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Searching for", nil), query];
    [[Service getInstance] searchReservationsForText: query delegate:self callback:@selector(searchReservationsCallback:)];    
}

- (void) searchReservationsCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }
    NSMutableArray *reservations = serviceResult.data;
    if(reservations == nil || [reservations count] == 0)
        searchHeader.text = NSLocalizedString(@"No reservations found", nil);
    else
        searchHeader.text = NSLocalizedString(@"Reservations found:", nil);

    ReservationDataSource *dataSource = [ReservationDataSource dataSourceWithDate: nil includePlacedReservations: YES withReservations:reservations];
    if(self.dayView != nil) {
        self.dayView.dataSource = dataSource;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.dayView.table isEditing])
        [self edit];
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
 //               [cell setInfo:info];
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
