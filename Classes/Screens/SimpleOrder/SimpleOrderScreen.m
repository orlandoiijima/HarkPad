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
#import "OrderLineCell.h"
#import "Service.h"
#import "UserListViewController.h"
#import "User.h"
#import "ModalAlert.h"
#import "Utils.h"
#import "CrystalButton.h"
#import "TestFlight.h"
#import "BillPdf.h"
#import "MenuPanelViewController.h"
#import "MenuPanelView.h"
#import "PrintInfo.h"
#import "OrderPrinter.h"
#import "Logger.h"

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

- (void)didTapProduct:(Product *)product {
    if (product == nil) return;
    if ([_order.lines count] == 0)
        [self setupScreenForNewOrder];
    OrderLine *line = [_order addLineWithProductId:product.key seat:-1 course:-1];
    [self.dataSource tableView:self.orderView addLine:line];
    [self onOrderUpdated];
}

#pragma mark - View lifecycle

#define HEIGHT_CASHBUTTON 100
#define HEIGHT_CREDITBUTTON 60
#define WIDTH_REGISTER 300
#define WIDTH_MARGIN 5

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.title = NSLocalizedString(@"New order", nil);
    _previousOrder = nil;

    float margin = 5;
    float columnWidth = self.view.bounds.size.width - 3*WIDTH_MARGIN - WIDTH_REGISTER;
    float columnHeight = self.view.bounds.size.height - 2*margin;

    self.productView = [MenuPanelView viewWithFrame: CGRectMake(margin, margin, columnWidth, columnHeight) menuCard: [[Cache getInstance] menuCard] menuPanelShow:MenuPanelShowAll delegate: self];

    [self.view addSubview:self.productView];

    columnWidth = WIDTH_REGISTER;
    float x = 2*margin + self.productView.frame.size.width;
    float y = margin + 20;
    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, columnWidth, 80)];
    [self.view addSubview:self.amountLabel];
    self.amountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.amountLabel.alpha = 0;
    self.amountLabel.backgroundColor = [UIColor clearColor];
    self.amountLabel.textColor = [UIColor whiteColor];
    self.amountLabel.font = [UIFont systemFontOfSize:100];
    self.amountLabel.textAlignment = NSTextAlignmentCenter;

    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, columnWidth, 100)];
    [self.view addSubview:self.infoLabel];
    self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.infoLabel.alpha = 0;
    self.infoLabel.text = NSLocalizedString(@"Tap on product in left panel to start order", nil);
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.font = [UIFont systemFontOfSize:18];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;

    self.printInvoiceButton = [[CrystalButton alloc] initWithFrame: CGRectMake(
            x + (columnWidth - 200)/2,
            self.infoLabel.frame.origin.y + self.infoLabel.frame.size.height + 5,
            200,
            60)];
    [self.view addSubview:self.printInvoiceButton];
    self.printInvoiceButton.alpha = 0;
    [self.printInvoiceButton setTitle: NSLocalizedString(@"Print bill", nil) forState:UIControlStateNormal];
    self.printInvoiceButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.printInvoiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.printInvoiceButton addTarget:self action:@selector(printPreviousOrder) forControlEvents:UIControlEventTouchDown];

    y += self.amountLabel.bounds.size.height + 20;
    self.orderView = [[UITableView alloc] initWithFrame:CGRectMake(
            x,
            y,
            columnWidth,
            columnHeight - y - HEIGHT_CASHBUTTON - HEIGHT_CREDITBUTTON - 5 - 5) style:UITableViewStyleGrouped];
    self.orderView.backgroundView = nil;
    self.orderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.orderView];

    y += self.orderView.bounds.size.height + 5;
    self.cashButton = [[CrystalButton alloc] initWithFrame: CGRectMake(
            x + (columnWidth - 300)/2,
            y,
            300,
            HEIGHT_CASHBUTTON)];
    [self.view addSubview:self.cashButton];
    self.cashButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.cashButton.alpha = 0;
    [self.cashButton setTitle: NSLocalizedString(@"Cash", nil) forState:UIControlStateNormal];
    self.cashButton.titleLabel.font = [UIFont boldSystemFontOfSize:50];
    [self.cashButton addTarget:self action:@selector(cashOrder) forControlEvents:UIControlEventTouchDown];

    y += self.cashButton.bounds.size.height + 5;
    self.orderButton = [[CrystalButton alloc] initWithFrame:
            CGRectMake(
                    x + (columnWidth - 300)/2,
                    y,
                    300,
                    HEIGHT_CREDITBUTTON)];
    [self.view addSubview:self.orderButton];
    [self.orderButton setTitle: NSLocalizedString(@"Credit", nil) forState:UIControlStateNormal];
    self.orderButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.orderButton.alpha = 0;
    [self.orderButton addTarget:self action:@selector(selectOrder) forControlEvents:UIControlEventTouchDown];

//    [self.productView reloadData];

    [self prepareForNewOrder];
}

- (IBAction) cashOrder
{
    _order.paymentType = Cash;
    [[Service getInstance] createOrder:_order success:^(ServiceResult *serviceResult){
        _order.id = serviceResult.id;
        OrderPrinter *printer = [OrderPrinter printerAtTrigger: TriggerOrder order: _order];
        [printer print];
        _previousOrder = _order;
        [self prepareForNewOrder];
        [self setupStartScreen];
    }
    error: ^(ServiceResult *serviceResult) {
        [serviceResult displayError];
    }];
}


- (IBAction) selectOrder
{
    SelectOpenOrder *selectOpenOrder = [[SelectOpenOrder alloc] initWithType:typeSelection title: NSLocalizedString(@"Select running order", nil)];
    selectOpenOrder.delegate = self;
    [self.navigationController pushViewController:selectOpenOrder animated:YES];
}

- (void) printPreviousOrder
{
    [Logger info: @"Print order"];
    if(_previousOrder == nil) return;

    OrderPrinter *printer = [OrderPrinter printerAtTrigger: TriggerBill order:_previousOrder];
    if ([printer countAvailableDocumentDefinitions] == 0) {
        [ModalAlert error:@"No documentdefinitions available"];
        return;
    }
    [printer print];
}

- (void)didSelectItem:(id)item {
    
    if ([item isKindOfClass:[Order class]]) {
        Order *order = (Order *)item;
        for(OrderLine *line in _order.lines) {
            [order addOrderLine:line];
        }
        [self.navigationController popViewControllerAnimated:YES];
        [[Service getInstance] updateOrder:order success:^(ServiceResult *serviceResult){
            _previousOrder.id = serviceResult.id;
            [self prepareForNewOrder];
            [self setupStartScreen];
        }
        error:^(ServiceResult *serviceResult) {
            [serviceResult displayError];
        }];
    }
}


- (void) prepareForNewOrder {
    _order = [[Order alloc] init];
    self.dataSource = [OrderDataSource dataSourceForOrder:_order grouping:noGrouping totalizeProducts:NO showFreeProducts:YES showExistingLines:YES showProductProperties:NO isEditable:YES showPrice:YES showEmptySections:NO fontSize: 0];
    self.dataSource.delegate = self;
    self.dataSource.sortOrder = sortByCreatedOn;
    self.orderView.dataSource = self.dataSource;
    self.orderView.delegate = self.dataSource;
    [self.orderView reloadData];
    [self setupStartScreen];
}

- (void) onOrderUpdated {
    amountLabel.text = [Utils getAmountString: [_order totalAmount] withCurrency:NO];
    if([_order.lines count] == 0) {
        [self setupStartScreen];
    }
}

- (void)didUpdateOrder:(Order *)order {
    [self onOrderUpdated];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TestFlight passCheckpoint: [[self class] description]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
