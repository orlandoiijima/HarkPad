//
//  PaymentViewController.m
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "BillViewController.h"
#import "Service.h"
#import "Utils.h"

@implementation BillViewController

@synthesize orderTable, goButton, printerSegment, amountLabel, tableLabel, order,dataSource, groupingSegment, tableMapViewController, nameLabel, backButton;

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
        
        self.dataSource = [InvoiceDataSource dataSourceForOrder:order grouping:byCategory totalizeProducts:YES showFreeProducts:NO showProductProperties:YES];
    }
}

- (IBAction) goPrint
{
    NSString *printer = [printerSegment titleForSegmentAtIndex: printerSegment.selectedSegmentIndex];
    [[Service getInstance] makeBills:nil forOrder: order.id withPrinter: [printer lowercaseString]]; 
    [tableMapViewController closeOrderView];
}

- (IBAction) goBack
{
    [tableMapViewController closeOrderView];    
}

- (IBAction) changeGrouping
{
    dataSource.grouping = groupingSegment.selectedSegmentIndex + 1;
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
    amountLabel.text = [NSString stringWithFormat:@"%@", [Utils getAmountString: [order getAmount] withCurrency:YES]];
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
