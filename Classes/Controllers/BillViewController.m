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

@synthesize orderTable, goButton, printerSegment, amountLabel, tableLabel, order,dataSource, groupingSegment, nameLabel, backButton;

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
        
        self.dataSource = [OrderDataSource dataSourceForOrder:order grouping:byCategory totalizeProducts:YES showFreeProducts:NO showProductProperties:YES isEditable:NO showPrice:YES];
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

- (IBAction) goPrint
{
    NSString *printer = [printerSegment titleForSegmentAtIndex: printerSegment.selectedSegmentIndex];
    [[Service getInstance] makeBills:nil forOrder: order.id withPrinter: [printer lowercaseString]]; 
    [self.navigationController popViewControllerAnimated:YES];
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

    self.title = NSLocalizedString(@"Bill", nil);
    [self setupToolbar];

    tableLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Table", nil), order.table.name];
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
