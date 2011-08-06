	//
//  ScrollTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 01-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ScrollTableViewController.h"
#import "iToast.h"
#import "ReservationTableCell.h"
#import "Service.h"

@implementation ScrollTableViewController

@synthesize scrollView, currentPage, nextPage, dataSources, originalStartsOn, popover, segmentShow, slider, buttonAdd, buttonEdit, buttonPhone, toolbar, buttonWalkin;

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

- (void)dealloc
{
    [scrollView release];
    [super dealloc];
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

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        buttonPhone.enabled = false;
    }
    else
    {
        buttonAdd.enabled = false;
        buttonWalkin.enabled = false;
        buttonEdit.enabled = false;
    }
    
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * TOTALDAYS, scrollView.bounds.size.height);
    scrollView.directionalLockEnabled = YES; 	
    scrollView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    currentPage = [[[ReservationDayView alloc] initWithFrame:frame delegate:self] autorelease];
    [scrollView addSubview:currentPage];
    
    frame = CGRectOffset(frame, scrollView.bounds.size.width, 0);
    nextPage = [[[ReservationDayView alloc] initWithFrame:frame delegate:self] autorelease];
    [scrollView addSubview:nextPage];
    
    dataSources = [[NSMutableDictionary alloc] init];
    [self gotoDayoffset:7];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];   
    
//    ReservationDataSource *dataSource = [ReservationDataSource dataSource:[NSDate date] includePlacedReservations: YES];
//    NSString *key = [self dateToKey:[NSDate date]];
//    [dataSources setObject:dataSource forKey:key];
//    currentPage.dataSource = dataSource;    
}

- (void) refreshView
{
    if(currentPage == nil) return;
    if(currentPage.dataSource == nil) return;
    [[Service getInstance] getReservations: currentPage.dataSource.date delegate:self callback:@selector(getReservationsCallback:onDate:)];    
}

- (void) getReservationsCallback: (NSMutableArray *)reservations onDate: (NSDate *)date
{
    if(currentPage == nil) return;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    ReservationDataSource *dataSource = [ReservationDataSource dataSource:date includePlacedReservations: includeSeated withReservations:reservations];
    NSString *key = [self dateToKey: dataSource.date];
    [dataSources setObject: dataSource forKey:key];
    if([currentPage.dataSource.date isEqualToDateIgnoringTime:date]) {
        currentPage.dataSource = dataSource;
    }
    
}

- (NSDate *)pageToDate: (int)page
{
    return [[NSDate date] dateByAddingDays:page - 7];
}

- (NSString *) dateToKey: (NSDate *)date
{
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"dd-MM-yy"];
    return [format stringFromDate:date];
}

- (void) setupScrolledInPage: (int)page
{
    NSDate *date = [self pageToDate:page];
    NSString *key = [self dateToKey: date];
    CGFloat pageWidth = scrollView.frame.size.width;
    nextPage.frame = CGRectMake(pageWidth * page, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    ReservationDataSource *dataSource = [dataSources objectForKey:key];
    if(dataSource == nil) {
        dataSource = [ReservationDataSource dataSource:date includePlacedReservations:YES];
        [dataSources setObject: dataSource forKey:key];
    }
    if(nextPage.dataSource == nil || [nextPage.dataSource.date isEqualToDateIgnoringTime:date] == false) {
        nextPage.dataSource = dataSource;
        NSLog(@"Updated datasource");
    }
    
    int mainPage = floor((self.scrollView.contentOffset.x + pageWidth / 2) / pageWidth);    
    if(mainPage == page)
    {
        ReservationDayView *swp = currentPage;
        currentPage = nextPage;
        nextPage = swp;
        slider.value = mainPage;
        if(currentPage.dataSource.includePlacedReservations)
            segmentShow.selectedSegmentIndex = 1;
        else
            segmentShow.selectedSegmentIndex = 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	int lowerPage = floor(fractionalPage);
    int upperPage = lowerPage + 1;
    
	NSDate *lowerDate = [self pageToDate:lowerPage];
	    
    ReservationDataSource *currentDataSource = currentPage.dataSource;
	if ([lowerDate isEqualToDateIgnoringTime: currentDataSource.date])
	{
        [self setupScrolledInPage:upperPage];
	}
    else
    {
        [self setupScrolledInPage:lowerPage];
    }
}

- (void) gotoDayoffset: (int)page
{
    NSDate *date = [self pageToDate:page];
    NSString *key = [self dateToKey: date];
    CGFloat pageWidth = scrollView.frame.size.width;
    currentPage.frame = CGRectMake(pageWidth * page, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    nextPage.frame = CGRectMake(pageWidth * (page + 1), 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    scrollView.contentOffset = CGPointMake(pageWidth * page, scrollView.contentOffset.y);
    ReservationDataSource *dataSource = [dataSources objectForKey:key];
    if(dataSource == nil) {
        dataSource = [ReservationDataSource dataSource:date includePlacedReservations:YES];
        [dataSources setObject: dataSource forKey:key];
    }
    currentPage.dataSource = dataSource;
}

- (IBAction) sliderUpdate
{
    int page = slider.value; 	
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
    Reservation *reservation = [currentPage selectedReservation];
    if(reservation == nil) return;
}

- (void) editMode
{
    if(currentPage == nil || currentPage.table == nil) return;
    if([currentPage.table isEditing])
        [currentPage.table setEditing:NO];
    else
        [currentPage.table setEditing:YES];
}

- (void) edit
{
    Reservation *reservation = [currentPage selectedReservation];
    if(reservation == nil || reservation.id == 0) return;
    originalStartsOn = [reservation.startsOn copyWithZone:nil];
    [self openEditPopup:reservation];
}	

- (void) call
{
    Reservation *reservation = [currentPage selectedReservation];
    if(reservation == nil || reservation.phone == @"") return;
    NSString *phoneNumber = [@"tel://" stringByAppendingString:reservation.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}	

- (void) showMode
{
    ReservationDataSource *dataSource = (ReservationDataSource*)currentPage.dataSource;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    if(dataSource.includePlacedReservations == includeSeated)
        return;
    [dataSource tableView: currentPage.table includeSeated: includeSeated];
}			

- (void) closePopup
{
    ReservationViewController *popup = (ReservationViewController *) popover.contentViewController;
    Reservation *reservation = popup.reservation;
    [popover dismissPopoverAnimated:YES];
    ReservationDataSource *dataSource = (ReservationDataSource*)currentPage.dataSource;
    if(reservation.id == 0)
    {
        [dataSource addReservation:reservation fromTableView:currentPage.table];
    }
    else
    {
        if([reservation.startsOn isEqualToDate: originalStartsOn]) {
            NSIndexPath *indexPath = [currentPage.table indexPathForSelectedRow];
            [currentPage.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            NSDate *startsOn = reservation.startsOn;
            reservation.startsOn = originalStartsOn;
            [dataSource deleteReservation:reservation fromTableView:currentPage.table];
            if([startsOn isEqualToDateIgnoringTime: currentPage.dataSource.date]) {
                reservation.startsOn = startsOn;
                [dataSource addReservation:reservation fromTableView:currentPage.table];
            }
        }
    }
    [currentPage refreshTotals:dataSource];
    [currentPage.table setEditing:NO];
}

- (void) cancelPopup
{
    [popover dismissPopoverAnimated:YES];
}

- (IBAction) add
{
    Reservation *reservation = [[Reservation alloc] init];
    NSDate *date = currentPage.dataSource.date;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:-1 fromDate:date];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([currentPage.table isEditing])
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
