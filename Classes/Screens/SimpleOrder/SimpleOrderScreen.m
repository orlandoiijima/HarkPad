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
@synthesize previousOrder = _previousOrder;
@synthesize dataSource, cashButton, orderButton, amountLabel, popoverController, infoLabel, printInvoiceButton;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didTapProduct:(Product *)product {
    if (product == nil) return;
    if ([_order.lines count] == 0)
        [self setupScreenForNewOrder];
    OrderLine *line = [_order addLineWithProductId:product.id seat:-1 course:-1];
    [self.dataSource tableView:self.orderView addLine:line];
    [self onOrderUpdated];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.title = NSLocalizedString(@"Nieuwe order", nil);

    float margin = 5;
    float columnWidth = (self.view.bounds.size.width - 3*margin) / 2;
    float columnHeight = self.view.bounds.size.height - 2*margin - 200;

    self.productView = [[MenuTreeView alloc] initWithFrame:CGRectMake(margin, margin, columnWidth, columnHeight)];
    [self.view addSubview:self.productView];
    self.productView.menuDelegate = self;
    self.productView.leftHeaderWidth = 20;
    self.productView.topHeaderHeight = 20;
    self.productView.cellPadding = CGSizeMake(3, 3);
    [self.productView setNeedsDisplay];
    self.productView.tapStyle = tapNothing;

    float x = 2*margin + self.productView.frame.size.width;
    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, margin+20, columnWidth, 80)];
    [self.view addSubview:self.amountLabel];
    self.amountLabel.alpha = 0;
    self.amountLabel.backgroundColor = [UIColor clearColor];
    self.amountLabel.textColor = [UIColor whiteColor];
    self.amountLabel.font = [UIFont systemFontOfSize:100];
    self.amountLabel.textAlignment = UITextAlignmentCenter;

    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, margin+20, columnWidth, 100)];
    [self.view addSubview:self.infoLabel];
    self.infoLabel.alpha = 0;
    self.infoLabel.text = NSLocalizedString(@"Tap op product in linkerpanel voor nieuwe bestelling", nil);
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.font = [UIFont systemFontOfSize:18];
    self.infoLabel.textAlignment = UITextAlignmentCenter;

    self.printInvoiceButton = [[CrystalButton alloc] initWithFrame: CGRectMake(
            x + (columnWidth - 200)/2,
            self.infoLabel.frame.origin.y + self.infoLabel.frame.size.height + 5,
            200,
            60)];
    [self.view addSubview:self.printInvoiceButton];
    self.printInvoiceButton.alpha = 0;
    [self.printInvoiceButton setTitle: NSLocalizedString(@"Bon afdrukken", nil) forState:UIControlStateNormal];
    self.printInvoiceButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.printInvoiceButton addTarget:self action:@selector(printPreviousOrder) forControlEvents:UIControlEventTouchDown];

    self.orderView = [[UITableView alloc] initWithFrame:CGRectMake(
            x,
            self.amountLabel.frame.origin.y + self.amountLabel.frame.size.height + 20,
            columnWidth,
            columnHeight - 2*self.amountLabel.frame.size.height - 20) style:UITableViewStyleGrouped];
    self.orderView.backgroundView = nil;
    [self.view addSubview:self.orderView];

    self.cashButton = [[CrystalButton alloc] initWithFrame: CGRectMake(
            x + (columnWidth - 300)/2,
            self.orderView.frame.origin.y + self.orderView.frame.size.height + 5,
            300,
            100)];
    [self.view addSubview:self.cashButton];
    self.cashButton.alpha = 0;
    [self.cashButton setTitle: NSLocalizedString(@"Contant", nil) forState:UIControlStateNormal];
    self.cashButton.titleLabel.font = [UIFont boldSystemFontOfSize:50];
    [self.cashButton addTarget:self action:@selector(cashOrder) forControlEvents:UIControlEventTouchDown];

    self.orderButton = [[CrystalButton alloc] initWithFrame:
            CGRectMake(
                    x + (columnWidth - 300)/2,
                    self.cashButton.frame.origin.y + self.cashButton.frame.size.height + 5,
                    300,
                    60)];
    [self.view addSubview:self.orderButton];
    [self.orderButton setTitle: NSLocalizedString(@"Op rekening", nil) forState:UIControlStateNormal];
    self.orderButton.alpha = 0;
    [self.orderButton addTarget:self action:@selector(selectOrder) forControlEvents:UIControlEventTouchDown];

    [self.productView reloadData];

    [self prepareForNewOrder];
}

- (IBAction) cashOrder
{
    [[Service getInstance] quickOrder:_order paymentType:0 printInvoice:NO delegate:self callback:@selector(cashOrderCallback:)];
}

- (void) cashOrderCallback: (ServiceResult *)serviceResult
{
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }
    _order.id = serviceResult.id;
    _previousOrder = _order;
    [self prepareForNewOrder];
    [self setupStartScreen];
}

- (IBAction) selectOrder
{
    SelectOpenOrder *selectOpenOrder = [[SelectOpenOrder alloc] initWithType:typeSelection title: NSLocalizedString(@"Kies openstaande order", nil)];
    selectOpenOrder.delegate = self;
    [self.navigationController pushViewController:selectOpenOrder animated:YES];
}

- (void) printPreviousOrder
{
    if(_previousOrder == nil) return;
    [[Service getInstance] printInvoice:_previousOrder.id];
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
    self.dataSource = [OrderDataSource dataSourceForOrder:_order grouping:noGrouping totalizeProducts:NO showFreeProducts:YES showProductProperties:NO isEditable:YES showPrice:YES];
    self.dataSource.delegate = self;
    self.dataSource.sortOrder = sortByCreatedOn;
    self.orderView.dataSource = self.dataSource;
    self.orderView.delegate = self.dataSource;
    [self.orderView reloadData];
    [self setupStartScreen];
}

- (void) onOrderUpdated {
    amountLabel.text = [Utils getAmountString: [_order getAmount] withCurrency:NO];
    if([_order.lines count] == 0) {
        [self setupStartScreen];
    }
}

- (void) setupStartScreen
{
    [UIView animateWithDuration:0.6
                 animations:^{
                     //  Hide items that are only used when an order is being entered
                     amountLabel.alpha = 0;
                     cashButton.alpha = 0;
                     orderButton.alpha = 0;

                     infoLabel.alpha = 1;
                     printInvoiceButton.alpha = _previousOrder != nil ? 1 : 0;
                 }
     ];
    [self.view bringSubviewToFront:printInvoiceButton];
    printInvoiceButton.enabled = YES;
}

- (void) setupScreenForNewOrder
{
    [UIView animateWithDuration:0.6
                 animations:^{
                    //  Show items that are used when an order is being entered
                    amountLabel.alpha = 1;
                    cashButton.alpha = 1;
                    orderButton.alpha = 1;

                    infoLabel.alpha = 0;
                    printInvoiceButton.alpha = 0;
                 }
   ];
    printInvoiceButton.enabled = NO;
}

- (void)updatedCell:(UITableViewCell *)cell {
    OrderLineCell *orderLineCell = (OrderLineCell *)cell;
    if (orderLineCell != nil) {
        if (orderLineCell.orderLine.quantity == 0) {
            [self.dataSource tableView: self.orderView removeOrderLine: orderLineCell.orderLine];
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
