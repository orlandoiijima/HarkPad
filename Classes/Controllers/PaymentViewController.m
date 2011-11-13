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

@synthesize orderTable, delegate, goButton, paymentType, amountLabel, tableLabel, order,dataSource, groupingSegment, nameLabel, backButton;

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
        
        dataSource = [OrderDataSource dataSourceForOrder:order grouping:byCategory totalizeProducts:YES showFreeProducts:NO showProductProperties:YES isEditable:NO];
    }
}

- (IBAction) goPay
{
    int type = paymentType.selectedSegmentIndex + 1;
    [[Service getInstance] processPayment:type forOrder:order.id];
    if([self.delegate respondsToSelector:@selector(didProcessPaymentType:forOrder:)])
        [self.delegate didProcessPaymentType:type forOrder:order];
}

- (IBAction) goBack
{
    if([self.delegate respondsToSelector:@selector(didProcessPaymentType:forOrder:)])
        [self.delegate didProcessPaymentType:0 forOrder:order];
}

- (IBAction) changeGrouping
{
    dataSource.grouping = groupingSegment.selectedSegmentIndex;
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
    // Do any additional setup after loading the view from its nib.
    
    tableLabel.text = [NSString stringWithFormat:@"Tafel %@", order.table.name];    
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
