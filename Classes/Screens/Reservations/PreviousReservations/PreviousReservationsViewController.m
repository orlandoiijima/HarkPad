//
//  PreviousReservationsViewController.m
//  HarkPad
//
//  Created by Willem Bison on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "PreviousReservationsViewController.h"
#import "Service.h"
#import "ModalAlert.h"
#import "ReservationDataSource.h"
#import "OrderDataSource.h"

@interface PreviousReservationsViewController ()

@end

@implementation PreviousReservationsViewController

@synthesize orderTableView, reservationsTableView,reservationId;
@synthesize reservationDataSource = _reservationDataSource;
@synthesize orderDataSource = _orderDataSource;
@synthesize headerLabel;

+ (PreviousReservationsViewController *) controllerWithReservationId: (int) reservationId {
    PreviousReservationsViewController *controller = [[PreviousReservationsViewController alloc] init];
    controller.reservationId = reservationId;
    [[Service getInstance] getPreviousReservationsForReservation: reservationId delegate: controller callback:@selector(getReservationsCallback:)];
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat margin = 20;

    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, self.view.bounds.size.width, 30)];
    self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerLabel.text = NSLocalizedString(@"Previous reservations:", nil);
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.headerLabel];

    CGFloat y = self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height+5;
    self.reservationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(margin, y, (self.view.bounds.size.width-3*margin)/2, self.view.bounds.size.height - y - margin) style:UITableViewStyleGrouped];
    self.reservationsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.reservationsTableView];
    self.reservationsTableView.delegate = self;
    self.orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.reservationsTableView.bounds.size.width+2*margin, y, (self.view.bounds.size.width-3*margin)/2, self.view.bounds.size.height - y - margin) style:UITableViewStyleGrouped];
    self.orderTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:self.orderTableView];
    self.orderTableView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) getReservationsCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }
    NSMutableArray *reservations = serviceResult.data;
    if ([reservations count] == 0) {
        self.headerLabel.text = NSLocalizedString(@"No reservations found", <#comment#>);
        self.reservationsTableView.hidden = YES;
        self.orderTableView.hidden = YES;
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
    }
    self.reservationDataSource = [ReservationDataSource dataSourceWithDate:nil includePlacedReservations:YES withReservations:reservations];
    self.reservationsTableView.dataSource = self.reservationDataSource;
    [self.reservationsTableView reloadData];
    if ([reservations count] > 0)
        [self.reservationsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reservation *reservation = [self.reservationDataSource getReservation:indexPath];

    [[Service getInstance]
            getOrder:reservation.orderId
             success:^(ServiceResult *serviceResult){
                Order *order = [Order orderFromJsonDictionary:serviceResult.jsonData];
                 self.orderDataSource = [OrderDataSource dataSourceForOrder:order grouping:bySeat totalizeProducts:YES showFreeProducts:NO showProductProperties:NO isEditable:NO showPrice:NO showEmptySections:NO fontSize:14];
                 self.orderTableView.dataSource = self.orderDataSource;
                 [self.orderTableView reloadData];
            }
               error:^(ServiceResult *serviceResult) {
                [serviceResult displayError];
                }];
}

- (CGFloat)tableView:(UITableView *)view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (view == self.orderTableView)
        return 26;
    else
        return 44;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
