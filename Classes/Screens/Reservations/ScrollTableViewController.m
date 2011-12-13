//
//  ScrollTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 01-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ScrollTableViewController.h"
#import "iToast.h"
#import "Service.h"
#import "CalendarDayCell.h"
#import "DayReservationsInfo.h"

@implementation ScrollTableViewController

@synthesize dayView, dataSources, originalStartsOn, popover, segmentShow, buttonAdd, buttonEdit, buttonPhone, toolbar, buttonWalkin, isInSearchMode, searchBar, saveDate, buttonSearch, searchHeader, calendarViews;

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

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [toolbar setItems:nil animated:NO];
        [toolbar setItems: [[NSArray alloc] initWithObjects:buttonPhone, buttonSearch, nil]]; 
        buttonSearch.width = 130;
    }
    else
    {
        buttonPhone.enabled = false;
    }

    calendarViews = [[NSMutableArray alloc] init];
    int margin = 10;
    int top = 60;
    int width = (self.view.bounds.size.width - 3*margin) / 2;
    int height = (self.view.bounds.size.height - 3 * margin - top) / 3;
    int y = top;
    for(int month = 0; month < 3; month++) {
        CalendarMonthView *view = [[CalendarMonthView alloc] initWithFrame:CGRectMake(margin, y, width, height)];
        [self.view addSubview:view];
        view.calendarDelegate = self;
        view.startMonth = [[[NSDate date] dateByAddingDays:30 * month] month];
        view.startYear = [[[NSDate date] dateByAddingDays:30 * month] year];
        [calendarViews addObject:view];
        [view reloadData];
        y += height + margin;
    }
    [self refreshCalendar];

    CGRect frameDay = CGRectMake(self.view.bounds.size.width/2, top, self.view.bounds.size.width/2, self.view.bounds.size.height - 50);
    self.dayView = [[ReservationDayView alloc] initWithFrame:frameDay delegate:self];
    [self.view addSubview:dayView];

    self.dataSources = [[NSMutableDictionary alloc] init];
    [self gotoDate:[NSDate date]];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
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
    ReservationDataSource *dataSource = [ReservationDataSource dataSource:date includePlacedReservations: includeSeated withReservations:reservations];
    NSString *key = [self dateToKey: dataSource.date];
    [dataSources setObject: dataSource forKey:key];
    if([dayView.date isEqualToDateIgnoringTime:date]) {
        dayView.dataSource = dataSource;
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
    ReservationViewController *popup = [ReservationViewController initWithReservation: reservation];
    popover = [[UIPopoverController alloc] initWithContentViewController: popup];
    popup.hostController = self;
    popover.delegate = self;
    
    [popover presentPopoverFromRect:CGRectMake(0,0,10,10) inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (void)createFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Reservation *reservation = (Reservation *)fetcher.userData;
    if(reservation == nil) return;
    
    ServiceResult *serviceResult = [ServiceResult resultFromData:data error:error];
    if(serviceResult.id != -1) {
        reservation.id = serviceResult.id;
        [[iToast makeText:NSLocalizedString(@"Reservation stored", @"Reservation stored")] show];
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
    ReservationViewController *popup = (ReservationViewController *) popover.contentViewController;
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

- (void) searchReservationsCallback: (NSMutableArray *)reservations
{
    if(reservations == nil || [reservations count] == 0)
        searchHeader.text = NSLocalizedString(@"No reservations found", nil);
    else
        searchHeader.text = NSLocalizedString(@"Reservations found:", nil);

    ReservationDataSource *dataSource = [ReservationDataSource dataSource: nil includePlacedReservations: YES withReservations:reservations];
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
    NSDate *fromDate = [[calendarViews objectAtIndex:0] firstDateInView];
    NSDate *toDate = [[calendarViews objectAtIndex:[calendarViews count]-1] lastDateInView];
    Service *service = [Service getInstance];
//    service.url = @"http://pos.restaurantanna.nl";
    [service getCountAvailableSeatsPerSlotFromDate:fromDate toDate:toDate delegate:self callback:@selector(refreshCalendarCallback:)];
}

- (void) refreshCalendarCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }

    NSMutableDictionary *reservations = [[NSMutableDictionary alloc] init];
    for(id item in serviceResult.jsonData) {
        DayReservationsInfo *info = [DayReservationsInfo infoFromJsonDictionary:item];
        [reservations setObject:info forKey:[info.date inJson]];
    }
    for(CalendarMonthView *calendarView in self.calendarViews) {
        for(int week = 0; week < 10; week++) {
            for(int day = 0; day < 7; day++) {
                CalendarDayCell *cell = (CalendarDayCell *)[calendarView cellAtColumn:day row: week];
                if (cell != nil) {
                    NSString *key = [cell.date inJson];
                    DayReservationsInfo *info = [reservations objectForKey:key];
                    if (info != nil) {
                        cell.dinnerStatus = info.dinnerStatus;
                        cell.lunchStatus = info.lunchStatus;
                    }
                }
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
    // Return YES for supported orientations
	return YES;
}

	@end
