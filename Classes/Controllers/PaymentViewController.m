//
//  PaymentViewController.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "PaymentViewController.h"
#import "Service.h"
#import "Utils.h"

@implementation PaymentViewController

@synthesize orderTable, delegate, goButton, paymentType, amountLabel, tableLabel, order,dataSource, groupingSegment, nameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setOrder: (Order *) newOrder
{
    if(order != newOrder)
    {
        order = newOrder;
        
        dataSource = [OrderDataSource dataSourceForOrder:order grouping:byCategory totalizeProducts:YES showFreeProducts:NO showExistingLines:YES showProductProperties:YES isEditable:NO showPrice:YES showEmptySections:NO fontSize:0];
    }
}

- (void) setupToolbar {
    self.navigationItem.leftItemsSupplementBackButton = YES;
    groupingSegment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 200, 33)];
    groupingSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [groupingSegment insertSegmentWithTitle:NSLocalizedString(@"Seat", nil) atIndex:0 animated:NO];
    [groupingSegment insertSegmentWithTitle:NSLocalizedString(@"Course", nil) atIndex:1 animated:NO];
    [groupingSegment insertSegmentWithTitle:NSLocalizedString(@"Category", nil) atIndex:2 animated:NO];
    groupingSegment.selectedSegmentIndex = 2;
    [groupingSegment addTarget:self action:@selector(changeGrouping) forControlEvents:UIControlEventValueChanged];

    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
            [[UIBarButtonItem alloc] initWithCustomView: groupingSegment],
            nil];
}

- (IBAction) goPay
{
    int type = paymentType.selectedSegmentIndex + 1;
    [[Service getInstance] processPayment:type forOrder:order.id];
    if([self.delegate respondsToSelector:@selector(didProcessPaymentType:forOrder:)])
        [self.delegate didProcessPaymentType:type forOrder:order];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) changeGrouping
{
    dataSource.grouping = (OrderGrouping) (groupingSegment.selectedSegmentIndex + 1);
    [orderTable reloadData];
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

    [self setupToolbar];
    self.title = NSLocalizedString(@"Payment", nil);
    
    if (order.table == nil) {
        tableLabel.text = order.reservation == nil ? order.name : order.reservation.name;
        nameLabel.text = @"";
    }
    else {
        tableLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Table", nil), order.table.name];
        nameLabel.text = order.reservation == nil ? order.name : order.reservation.name;
    }
    orderTable.dataSource = dataSource;
    orderTable.delegate = dataSource;
    amountLabel.text = [Utils getAmountString:[order totalAmount] withCurrency:YES];

    orderTable.backgroundView = nil;
    orderTable.backgroundColor = [UIColor clearColor];
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
