//
//  OrderLinesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "OrderLinesViewController.h"
#import "InvoiceDataSource.h"

@implementation OrderLinesViewController

@synthesize order, invoicesViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    InvoiceDataSource *dataSource = [InvoiceDataSource dataSourceForOrder:order grouping:byCourse totalizeProducts:NO showFreeProducts:NO];
    dataSource.invoicesViewController = invoicesViewController;
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = self;
    if(order.state != paid)
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
