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

@implementation ScrollTableViewController

@synthesize scrollView, dayView1, dayView2, dataSources, originalStartsOn, popover, segmentShow, slider, buttonAdd, buttonEdit, buttonPhone, toolbar, buttonWalkin, isInSearchMode, searchBar, saveDate, buttonSearch, searchHeader;

#define TOTALDAYS 60

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        slider.maximumValue = TOTALDAYS;				
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
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * TOTALDAYS, scrollView.bounds.size.height);
    scrollView.directionalLockEnabled = YES; 	
    scrollView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    self.dayView1 = [[ReservationDayView alloc] initWithFrame:frame delegate:self];
    [scrollView addSubview:dayView1];
    
    frame = CGRectOffset(frame, scrollView.bounds.size.width, 0);
    self.dayView2 = [[ReservationDayView alloc] initWithFrame:frame delegate:self];
    [scrollView addSubview:dayView2];
    
    self.dataSources = [[NSMutableDictionary alloc] init];
    [self gotoDayoffset:7];

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
        [self gotoDayoffset:7];
}

- (ReservationDayView *) currentDayView
{
    if(scrollView.contentOffset.x == dayView1.frame.origin.x)
        return dayView1;
    if(scrollView.contentOffset.x == dayView2.frame.origin.x)
        return dayView2;
    return nil;
}

- (void) refreshView
{
    if(self.currentDayView == nil) return;
    if(self.currentDayView.dataSource == nil || self.currentDayView.dataSource.date == nil) return;
    [[Service getInstance] getReservations: self.currentDayView.dataSource.date delegate:self callback:@selector(getReservationsCallback:onDate:)];    
}

- (void) getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date
{
    NSMutableArray *reservations = serviceResult.data;
    Reservation *selectedReservation = self.currentDayView.selectedReservation;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    ReservationDataSource *dataSource = [ReservationDataSource dataSource:date includePlacedReservations: includeSeated withReservations:reservations];
    NSString *key = [self dateToKey: dataSource.date];
    [dataSources setObject: dataSource forKey:key];
    if([dayView1.date isEqualToDateIgnoringTime:date]) {
        dayView1.dataSource = dataSource;
    }
    if([dayView2.date isEqualToDateIgnoringTime:date]) {
        dayView2.dataSource = dataSource;
    }    
    if(selectedReservation != nil)
        self.currentDayView.selectedReservation = selectedReservation;	
}

- (NSDate *)pageToDate: (int)page
{
    return [[NSDate date] dateByAddingDays:page - 7];
}

- (NSString *) dateToKey: (NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yy"];
    return [format stringFromDate:date];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if(isInSearchMode)
        [self endSearchMode];
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	int lowerPage = (int) floor(fractionalPage);
    int upperPage = lowerPage + 1;

	NSDate *lowerDate = [self pageToDate:lowerPage];
	NSDate *upperDate = [self pageToDate:upperPage];
    
    if([upperDate isEqualToDateIgnoringTime:dayView1.date] == false && [lowerDate isEqualToDateIgnoringTime:dayView1.date] == false)
    {
        //  dayView1 is scrolled out of view
        if([upperDate isEqualToDateIgnoringTime:dayView2.date])
        {
            //  and dayView2 uses upperdate -> use dayView1 for lowerDate
            [self setupDayView:dayView1 page:lowerPage];
        }
        else
        {
            [self setupDayView:dayView1 page:upperPage];
            
        }
    }
    else
    {
        if([upperDate isEqualToDateIgnoringTime:dayView2.date] == false && [lowerDate isEqualToDateIgnoringTime:dayView2.date] == false)
        {
            //  dayView2 is scrolled out of view
            if([upperDate isEqualToDateIgnoringTime:dayView1.date])
            {
                //  and dayView1 uses upperdate -> use dayView2 for lowerDate
                [self setupDayView:dayView2 page:lowerPage];
            }
            else
            {
                //  and dayView2 uses upperdate -> use dayView1 for lowerDate
                [self setupDayView:dayView2 page:upperPage];
                
            }
        }
    }

    slider.value = lowerPage;
    
//    if([lowerDate isEqualToDateIgnoringTime:dayView2.date])
//    {
//        [self setupDayView:dayView2 page:lowerPage];
//        slider.value = lowerPage;
//    }    
}

- (void) setupDayView: (ReservationDayView *)dayView page: (int)page
{
    dayView.frame = CGRectMake(scrollView.frame.size.width * page, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    dayView.date = [self pageToDate:page];
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

- (void) gotoDayoffset: (int)page
{
    if(isInSearchMode)
        [self endSearchMode];
    
    scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * page, scrollView.contentOffset.y);
    [self setupDayView:dayView1 page:page];
    [self setupDayView:dayView2 page:page+1];
    slider.value = page;
}

- (IBAction) sliderUpdate
{
    int page = (int) slider.value; 	
    [self gotoDayoffset:page];
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
        [[iToast makeText:@"Reservation stored"] show];
    }
    else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
    }
    return;
}

- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    Reservation *reservation = [self.currentDayView selectedReservation];
    if(reservation == nil) return;
}

- (void) editMode
{
    if(self.currentDayView == nil || self.currentDayView.table == nil) return;
    if([self.currentDayView.table isEditing])
        [self.currentDayView.table setEditing:NO];
    else
        [self.currentDayView.table setEditing:YES];
}

- (void) edit
{
    Reservation *reservation = [self.currentDayView selectedReservation];
    if(reservation == nil || reservation.id == 0) return;
    self.originalStartsOn = [reservation.startsOn copyWithZone:nil];
    [self openEditPopup:reservation];
}	

- (void) call
{
    Reservation *reservation = [self.currentDayView selectedReservation];
    if(reservation == nil || reservation.phone == nil || reservation.phone == @"") return;
    NSString *phoneNumber = [@"tel://" stringByAppendingString:reservation.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}	

- (void) showMode
{
    ReservationDataSource *dataSource = self.currentDayView.dataSource;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    if(dataSource.includePlacedReservations == includeSeated)
        return;
    [dataSource tableView: self.currentDayView.table includeSeated: includeSeated];
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
        dayViewNew = self.currentDayView;
        dataSourceNew = dayViewNew.dataSource;
    }
    else
    {        
        if([dayView1.date isEqualToDateIgnoringTime:reservation.startsOn])
            dayViewNew = dayView1;
        else
            if([dayView2.date isEqualToDateIgnoringTime:reservation.startsOn])
                dayViewNew = dayView2;
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
            [self.currentDayView.dataSource updateReservation:reservation fromTableView:self.currentDayView.table];
        }
        else {
            //  Edit, new day
            NSDate *startsOn = reservation.startsOn;
            reservation.startsOn = originalStartsOn;
            [self.currentDayView.dataSource deleteReservation:reservation fromTableView: self.currentDayView.table];

            reservation.startsOn = startsOn;
            [dataSourceNew addReservation:reservation fromTableView: dayViewNew.table];
        }
    }
    [self.currentDayView refreshTotals];
    [self.currentDayView.table setEditing:NO];
}
    
- (void) cancelPopup
{
    [popover dismissPopoverAnimated:YES];
}

- (IBAction) add
{
    Reservation *reservation = [[Reservation alloc] init];
    NSDate *date = self.currentDayView.dataSource.date;
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
    slider.hidden = NO;
    searchHeader.hidden = YES;
    [dayView1 showHeader];
    [dayView2 showHeader];
    NSString *key = [self dateToKey: saveDate];
    self.currentDayView.dataSource = [dataSources objectForKey:key];
}

- (void) startSearchForText: (NSString *) query
{
    isInSearchMode = YES;
    slider.hidden = YES;
    searchHeader.hidden = NO;
    
    [dayView1 hideHeader];
    [dayView2 hideHeader];
    saveDate = dayView1.date;
    searchHeader.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Zoeken naar ''", nil), query];
    [[Service getInstance] searchReservationsForText: query delegate:self callback:@selector(searchReservationsCallback:)];    
}

- (void) searchReservationsCallback: (NSMutableArray *)reservations
{
    if(reservations == nil || [reservations count] == 0)
        searchHeader.text = NSLocalizedString(@"Geen reserveringen gevonden", nil);
    else
        searchHeader.text = NSLocalizedString(@"Gevonden reserveringen:", nil);

    ReservationDataSource *dataSource = [ReservationDataSource dataSource: nil includePlacedReservations: YES withReservations:reservations];
    if(self.currentDayView != nil) {
        self.currentDayView.dataSource = dataSource;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.currentDayView.table isEditing])
        [self edit];
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
