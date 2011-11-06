//
//  SimpleOrderScreen.m
//  HarkPad
//
//  Created by Willem Bison on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SimpleOrderScreen.h"
#import "MenuTreeView.h"
#import "GridView.h"
#import "Order.h"
#import "OrderLineCell.h"
#import "Product.h"
#import "Service.h"
#import "SelectOpenOrder.h"

@implementation SimpleOrderScreen

@synthesize productView = _productView;
@synthesize orderView = _orderView;
@synthesize order = _order;


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

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapProduct:(Product *)product {
    if (product == nil) return;
    OrderLine *line = [_order addLineWithProductId:product.id seat:-1 course:-1];
    int row = [_order.lines indexOfObject:line];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.orderView beginUpdates];
    [self.orderView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.orderView endUpdates];

    [self.orderView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_order == nil) return 0;
    return [_order.lines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    }
    
    cell.orderLine = [_order.lines objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.productView.menuDelegate = self;
    self.productView.leftHeaderWidth = 0;
    self.productView.topHeaderHeight = 0;

    self.orderView.dataSource = self;

    _order = [[Order alloc] init];
}

- (IBAction) cashOrder
{
    [[Service getInstance] quickOrder:_order paymentType:0 printInvoice:NO delegate:self callback:nil];
}

- (IBAction) selectOrder
{
    SelectOpenOrder *selectOpenOrder = [[SelectOpenOrder alloc] init];
    [self.navigationController pushViewController:selectOpenOrder animated:YES];
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
