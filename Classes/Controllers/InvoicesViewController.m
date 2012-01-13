//
//  InvoicesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "InvoicesViewController.h"
#import "OrderLinesViewController.h"
#import "Invoice.h"
#import "Service.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "ModalAlert.h"

@implementation InvoicesViewController

@synthesize invoices, lastUpdate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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

    [self refresh];

    self.title = NSLocalizedString(@"Recent bills", nil);
}

- (void) getInvoicesCallback: (ServiceResult *)serviceResult
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];

    if(serviceResult.isSuccess == false) {
        [ModalAlert error:serviceResult.error];
        return;
    }

    [super dataSourceDidFinishLoadingNewData];
    self.lastUpdate = [NSDate date];

    self.invoices = serviceResult.data;
    [self.tableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) reloadTableViewDataSource
{
    [self refresh];
}

- (void) refresh
{
    [MBProgressHUD showProgressAddedTo:self.view withText:@""];
    [[Service getInstance] getInvoices:self callback:@selector(getInvoicesCallback:)];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section  != 0) return 0;
    return [invoices count];
}
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row < [invoices count]) {
        Invoice *invoice = [invoices objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        if (invoice.table != nil)
            cell.textLabel.text = [NSString stringWithFormat:@"Tafel %@ (%@)", invoice.table.name, [formatter stringFromDate:invoice.createdOn]];
        else
            cell.textLabel.text = [formatter stringFromDate:invoice.createdOn];
        cell.detailTextLabel.text = [Utils getAmountString:invoice.amount withCurrency:YES];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(invoice.paymentType == 0)
            cell.textLabel.textColor = [UIColor redColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Invoice *invoice = [self.invoices objectAtIndex:indexPath.row];
    // Navigation logic may go here. Create and push another view controller.
    OrderLinesViewController *controller = [[OrderLinesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.invoicesViewController = self;
    controller.order = [[Service getInstance] getOrder:invoice.orderId];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    controller.title = cell.textLabel.text;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) onUpdateOrder: (Order *)order
{
    for(Invoice *invoice in self.invoices)
    {
        if(invoice.orderId == order.id)
        {
            invoice.amount = [order getAmount];
            [self.tableView reloadData];
            return;
        }
    }
}

@end
