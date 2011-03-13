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

@implementation ReservationsTableViewController

@synthesize reservations, groupedReservations, table, dateToShow, dateLabel;


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

    reservations = [[[Service getInstance] getReservations] retain]	;
    
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
    
    [self refreshTable];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    int interval = sender.direction == UISwipeGestureRecognizerDirectionLeft ? 24*60*60 : -24*60*60;
    dateToShow = [[dateToShow dateByAddingTimeInterval: interval] retain]; 
    [self refreshTable];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    dateToShow = [[NSDate date] retain]; 
    [self refreshTable];
}

- (void) refreshTable
{
    if([dateToShow isToday])
        dateLabel.text = @"Vandaag";
    else if([dateToShow isYesterday])
        dateLabel.text = @"Gisteren";
    else if([dateToShow isTomorrow])
        dateLabel.text = @"Morgen";
    else if([dateToShow isAfterTomorrow])
        dateLabel.text = @"Overmorgen";
    else if([dateToShow isAfterYesterday])
        dateLabel.text = @"Eergisteren";
    else
        dateLabel.text = [NSString stringWithFormat:@"%@", dateToShow];

    groupedReservations = [[NSMutableDictionary alloc] init];
    for (Reservation *reservation in reservations) {
        if([dateToShow isEqualToDateIgnoringTime: reservation.startsOn]) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:reservation.startsOn];
            NSInteger hour = [components hour];
            NSInteger minute = [components minute];            
            NSString *timeSlot = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
            NSMutableArray *slotArray = [groupedReservations objectForKey:timeSlot];
            if(slotArray == nil) {
                slotArray = [[NSMutableArray alloc] init];
                [groupedReservations setObject:slotArray forKey:timeSlot];
            }
            [slotArray addObject:reservation];
        }
    }
    [table reloadData];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return groupedReservations.count == 0 ? 1 : groupedReservations.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(groupedReservations.count == 0)
        return 1;
    
    NSString *key = [[groupedReservations allKeys] objectAtIndex:section];
    
    NSArray *slotReservations = [groupedReservations objectForKey:key];
    if(slotReservations != nil)
        return slotReservations.count;
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(groupedReservations.count == 0)
        return @"";
    
    NSString *key = [[groupedReservations allKeys] objectAtIndex:section];
    return key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(groupedReservations == nil || groupedReservations.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cellx"];
        cell.textLabel.text = @"Geen reserveringen";
        return cell;
    }
    static NSString *CellIdentifier = @"Cell";
    
    ReservationTableCell *cell = (ReservationTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReservationTableCell" owner:self options:nil] lastObject];
    }
    NSString *key = [[groupedReservations allKeys] objectAtIndex: indexPath.section];
   
    NSArray *slotReservations = [groupedReservations objectForKey:key];

    Reservation *reservation = [slotReservations objectAtIndex:indexPath.row];
    cell.reservation = reservation;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
