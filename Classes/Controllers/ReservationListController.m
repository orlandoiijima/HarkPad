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

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) style:UITableViewStyleGrouped];
    self.view = tableView;

    [[Service getInstance] getReservations:[NSDate date] delegate:self callback:@selector(getReservationsCallback:onDate:)];
}

- (void)getReservationsCallback: (ServiceResult *)serviceResult onDate: (NSDate *)date {
    NSMutableArray *reservations = serviceResult.data;
    if ([reservations count] == 0) {
        if([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.delegate didSelectItem: [Reservation null]];
        }
    }
    self.dataSource = [ReservationDataSource dataSource:nil includePlacedReservations:NO withReservations: reservations];
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = self;
    self.contentSizeForViewInPopover = CGSizeMake(350, 400);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reservation *reservation = [self.dataSource.reservations objectAtIndex:indexPath.row];
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
