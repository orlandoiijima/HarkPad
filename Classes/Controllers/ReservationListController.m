//
//  ReservationListController.m
//  HarkPad
//
//  Created by Willem Bison on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReservationListController.h"
#import "SelectItemDelegate.h"
#import "Service.h"
#import "ReservationDataSource.h"

@implementation ReservationListController

@synthesize dataSource, tableView, delegate;

- (id)init {
    if ([super init]) {
        self.title = NSLocalizedString(@"Reservations", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"calendar.png"];
    }
    return self;
} 

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

- (UITableView *)tableView {
    return (UITableView *)self.view;
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.contentSizeForViewInPopover = CGSizeMake(200, 0);

    self.view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStyleGrouped];
    [[Service getInstance] getReservations:[NSDate date] delegate:self callback:@selector(getReservationsCallback:onDate:)];
}


- (void)getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date {
    NSMutableArray *reservations = serviceResult.data;
    if ([reservations count] == 0) {
        if([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.delegate didSelectItem: [Reservation null]];
        }
    }
    self.dataSource = [ReservationDataSource dataSourceWithDate:nil includePlacedReservations:NO withReservations: reservations];
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = self;
    self.contentSizeForViewInPopover = CGSizeMake(350, 400);
    [self.tableView reloadData];
    //   self.view.frame = CGRectMake(0, 0, 350, 400);
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reservation *reservation = [self.dataSource.reservations objectAtIndex: (NSUInteger)indexPath.row];
    if (reservation == nil) return;
    if([self.delegate respondsToSelector:@selector(didSelectItem:)])
        [self.delegate didSelectItem: reservation];
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
