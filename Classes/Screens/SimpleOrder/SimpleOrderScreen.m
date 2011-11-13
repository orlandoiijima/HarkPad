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
#import "OrderLineCell.h"
#import "Service.h"
#import "UserListViewController.h"
#import "User.h"
#import "ModalAlert.h"
#import "Utils.h"
#import "CrystalButton.h"

@implementation SimpleOrderScreen

@synthesize productView = _productView;
@synthesize orderView = _orderView;
@synthesize order = _order;
@synthesize dataSource, cashButton, orderButton, amountLabel, popoverController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapProduct:(Product *)product {
    if (product == nil) return;
    OrderLine *line = [_order addLineWithProductId:product.id seat:-1 course:-1];
    [self.dataSource tableView:self.orderView addLine:line];
    [self onOrderUpdated];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    float margin = 5;
    float columnWidth = (self.view.bounds.size.width - 3*margin) / 2;
    float columnHeight = self.view.bounds.size.height - 2*margin - 200;

    self.productView = [[MenuTreeView alloc] initWithFrame:CGRectMake(margin, margin, columnWidth, columnHeight)];
    [self.view addSubview:self.productView];
    self.productView.menuDelegate = self;
    self.productView.leftHeaderWidth = 20;
    self.productView.topHeaderHeight = 20;
    [self.productView setNeedsDisplay];
    self.productView.tapStyle = tapNothing;

    float x = 2*margin + self.productView.frame.size.width;
    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, margin, columnWidth, 80)];
    [self.view addSubview:self.amountLabel];
    self.amountLabel.backgroundColor = [UIColor clearColor];
    self.amountLabel.textColor = [UIColor whiteColor];
    self.amountLabel.font = [UIFont systemFontOfSize:100];
    self.amountLabel.textAlignment = UITextAlignmentCenter;

    self.orderView = [[UITableView alloc] initWithFrame:CGRectMake(
            x,
            self.amountLabel.frame.origin.y + self.amountLabel.frame.size.height,
            columnWidth,
            columnHeight - 2*self.amountLabel.frame.size.height) style:UITableViewStyleGrouped];
    self.orderView.backgroundView = nil;
    [self.view addSubview:self.orderView];

    self.cashButton = [[CrystalButton alloc] initWithFrame: CGRectMake(
            x,
            self.orderView.frame.origin.y + self.orderView.frame.size.height + 5,
            columnWidth,
            100)];
    [self.view addSubview:self.cashButton];
    [self.cashButton setTitle: NSLocalizedString(@"Contant", nil) forState:UIControlStateNormal];
    self.cashButton.titleLabel.font = [UIFont boldSystemFontOfSize:80];
    [self.cashButton addTarget:self action:@selector(cashOrder) forControlEvents:UIControlEventTouchDown];

    self.orderButton = [[CrystalButton alloc] initWithFrame:
            CGRectMake(
                    x,
                    self.cashButton.frame.origin.y + self.cashButton.frame.size.height + 5,
                    columnWidth,
                    60)];
    [self.view addSubview:self.orderButton];
    [self.orderButton setTitle: NSLocalizedString(@"Op rekening", nil) forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(selectOrder) forControlEvents:UIControlEventTouchDown];

    [self prepareForNewOrder];
}

//- (IBAction) selectUser
//{
//    UserListViewController *usersController = [[UserListViewController alloc] init];
//    usersController.delegate = self;
//
//    self.popoverController = [[UIPopoverController alloc] initWithContentViewController: usersController];
//    popoverController.delegate = self;
//
//    [popoverController presentPopoverFromRect:userButton.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//}

- (IBAction) cashOrder
{
    [[Service getInstance] quickOrder:_order paymentType:0 printInvoice:NO delegate:self callback:nil];
    [self prepareForNewOrder];
}

- (IBAction) selectOrder
{
    SelectOpenOrder *selectOpenOrder = [[SelectOpenOrder alloc] init];
    selectOpenOrder.delegate = self;
    [self.navigationController pushViewController:selectOpenOrder animated:YES];
}

- (void)didSelectItem:(id)item {
    
    if ([item isKindOfClass:[Order class]]) {
        Order *order = (Order *)item;
        for(OrderLine *line in _order.lines) {
            [order addOrderLine:line];
        }
        [self.navigationController popViewControllerAnimated:YES];
        [[Service getInstance] updateOrder:order];
        [self prepareForNewOrder];
    }

}

- (void) prepareForNewOrder {
    _order = [[Order alloc] init];
    self.dataSource = [OrderDataSource dataSourceForOrder:_order grouping:noGrouping totalizeProducts:NO showFreeProducts:YES showProductProperties:NO isEditable:YES];
    self.dataSource.delegate = self;
    self.orderView.dataSource = self.dataSource;
    self.orderView.delegate = self.dataSource;
    [self.orderView reloadData];
    [self onOrderUpdated];
}

- (void) onOrderUpdated {
    amountLabel.text = [Utils getAmountString: [_order getAmount] withCurrency:NO];
    amountLabel.hidden = [_order.lines count] == 0;
    cashButton.hidden = [_order.lines count] == 0;
    orderButton.hidden = [_order.lines count] == 0;
}

- (void)updatedCell:(UITableViewCell *)cell {
    OrderLineCell *orderLineCell = (OrderLineCell *)cell;
    if (orderLineCell != nil) {
        if (orderLineCell.orderLine.quantity == 0) {
            [self.dataSource removeOrderLine: orderLineCell.orderLine];
        }
    }
    [self onOrderUpdated];
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
