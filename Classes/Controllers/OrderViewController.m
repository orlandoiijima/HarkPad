//
//  OrderViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderViewDetailController.h"	

@implementation OrderListViewController

@synthesize orders;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewDidLoad {
    Service *service = [Service getInstance];
    orders = [service getOrders];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    if(indexPath.row < orders.count) {
    Order *order = [orders objectAtIndex:indexPath.row];
    NSString *tableName = [[order.tables objectAtIndex:0] name];
    cell.textLabel.text = [NSString stringWithFormat:@"Liness %d, Table: %@, Amount: %@", order.lines.count, tableName, order.getAmount];       
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void) tableView : (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    Service *service = [[Service alloc] init];
//    id orderId = [NSNumber numberWithInt:1];
    Order *order = [orders objectAtIndex:indexPath.row];
    OrderDetailViewController *detailController = [[OrderDetailViewController alloc] initWithOrder:order];
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
