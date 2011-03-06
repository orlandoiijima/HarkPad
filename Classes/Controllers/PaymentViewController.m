//
//  PaymentViewController.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "PaymentViewController.h"
#import "Service.h"

@implementation PaymentViewController

@synthesize orderTable, goButton, paymentType, amountLabel, tableLabel, order,dataSource, groupingSegment, tableMapViewController, nameLabel, backButton;

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
        [order release];
        order = [newOrder retain];
        
        dataSource = [InvoiceDataSource dataSourceForOrder:order grouping:byCategory];
    }
}

- (IBAction) goPay
{
    int type = paymentType.selectedSegmentIndex;
    [[Service getInstance] processPayment:type forOrder:order.id];
    [tableMapViewController closeOrderView];
}

- (IBAction) goBack
{
    [tableMapViewController closeOrderView];    
}

- (IBAction) changeGrouping
{
    dataSource.grouping = groupingSegment.selectedSegmentIndex;
    [orderTable reloadData];
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
    // Do any additional setup after loading the view from its nib.
    
    Table *table = [order.tables objectAtIndex:0];
    tableLabel.text = table.name;    
    orderTable.dataSource = dataSource;
    orderTable.delegate = dataSource;
    amountLabel.text = [NSString stringWithFormat:@"€ %0.2f", [[order getAmount] doubleValue]];
    nameLabel.text = order.reservation == nil ? @"" : order.reservation.name;
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
