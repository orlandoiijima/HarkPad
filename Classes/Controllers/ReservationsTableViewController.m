//
//  ReservationsTableViewController.m
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationsTableViewController.h"
#import "Service.h"
#import "ReservationTableCell.h"
#import "ReservationViewController.h"
#import "ReservationDataSource.h"
#import "ServiceResult.h"
#import "ModalAlert.h"

@implementation ReservationsTableViewController

@synthesize reservations, groupedReservations, table, dateToShow, dateLabel, popover, count1800, count1830, count1900, count1930, count2000, count2030, countTotal, segmentShow, isVisible, originalStartsOn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
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
    
    dateToShow = [[NSDate date] retain];

    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];   

    [NSTimer scheduledTimerWithTimeInterval:60.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];    
    
    [self reloadData];
}

- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    int interval = sender.direction == UISwipeGestureRecognizerDirectionLeft ? 24*60*60 : -24*60*60;
    dateToShow = [[dateToShow dateByAddingTimeInterval: interval] retain]; 
    [self reloadData];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    dateToShow = [[NSDate date] retain]; 
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isVisible = true;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isVisible = false;
}

- (void) reloadData
{
    bool includePlaced = [segmentShow selectedSegmentIndex] == 1;
    ReservationDataSource *dataSource = [ReservationDataSource dataSource:dateToShow includePlacedReservations: includePlaced];
    table.dataSource = dataSource;
    table.delegate = dataSource;
    
    [table reloadData];

    [self refreshView];
}

- (void) refreshView
{
    dateLabel.text = [dateToShow prettyDateString];
    
    ReservationDataSource *dataSource = (ReservationDataSource*)table.dataSource;
   
    int total = 0;
    int count = [dataSource countGuestsForKey:@"18:00"];
    total += count;
    count1800.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    count = [dataSource countGuestsForKey:@"18:30"];
    total += count;
    count1830.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    count = [dataSource countGuestsForKey:@"19:00"];
    total += count;
    count1900.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    count = [dataSource countGuestsForKey:@"19:30"];
    total += count;
    count1930.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    count = [dataSource countGuestsForKey:@"20:00"];
    total += count;
    count2000.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    count = [dataSource countGuestsForKey:@"20:30"];
    total += count;
    count2030.text = count == 0 ? @"-" : [NSString stringWithFormat:@"%d", count];
    
    countTotal.text = total == 0 ? @"-" : [NSString stringWithFormat:@"%d", total];
    countTotal.textColor = total == 0 ? [UIColor lightGrayColor] : [UIColor blackColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
    
    ServiceResult *serviceResult = [ServiceResult resultFromData:data];
    if(serviceResult.id != -1) {
        reservation.id = serviceResult.id;
    }
    else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
    }
    return;
}

- (void)updateFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
}

- (void) edit
{
    ReservationDataSource *dataSource = (ReservationDataSource*)table.dataSource;
    NSIndexPath *indexPath = [table indexPathForSelectedRow];
    Reservation *reservation = [dataSource getReservation:indexPath];
    if(reservation.id == 0) return;
    originalStartsOn = [reservation.startsOn copyWithZone:nil];
    [self openEditPopup:reservation];
}	

- (void) showMode
{
    ReservationDataSource *dataSource = (ReservationDataSource*)table.dataSource;
    bool includeSeated = segmentShow.selectedSegmentIndex == 1;
    [dataSource tableView: table includeSeated: includeSeated];
}			

- (void) closePopup
{
    ReservationViewController *popup = (ReservationViewController *) popover.contentViewController;
    Reservation *reservation = popup.reservation;
    [popover dismissPopoverAnimated:YES];
    ReservationDataSource *dataSource = (ReservationDataSource*)table.dataSource;
    if(reservation.id == 0)
    {
        [dataSource addReservation:reservation fromTableView:table];
    }
    else
    {
        if([reservation.startsOn isEqualToDate: originalStartsOn]) {
            NSIndexPath *indexPath = [table indexPathForSelectedRow];
            [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            NSDate *startsOn = reservation.startsOn;
            reservation.startsOn = originalStartsOn;
            [dataSource deleteReservation:reservation fromTableView:table];
            if([startsOn isEqualToDateIgnoringTime: dateToShow]) {
                reservation.startsOn = startsOn;
                [dataSource addReservation:reservation fromTableView:table];
            }
        }
    }
    [self refreshView];
}

- (void) cancelPopup
{
    [popover dismissPopoverAnimated:YES];
}

- (IBAction) add
{
    Reservation *reservation = [[Reservation alloc] init];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:-1 fromDate:dateToShow];
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

@end
