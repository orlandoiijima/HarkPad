//
//  SimpleOrderScreen.h
//  HarkPad
//
//  Created by Willem Bison on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuTreeView.h"
#import "Order.h"
#import "SelectOpenOrder.h"

@interface SimpleOrderScreen : UIViewController <MenuTreeViewDelegate, SelectItemDelegate, TableCellUpdated> {
    Order * _order;
}

@property (retain) MenuTreeView *productView;
@property (retain) UITableView *orderView;
@property (retain) UIButton *cashButton;
@property (retain) UIButton *orderButton;
@property (retain) UIButton *printInvoiceButton;
@property (retain) UILabel *amountLabel;
@property (retain) UILabel *infoLabel;
@property (retain) Order *order;
@property (retain) Order *previousOrder;
@property (retain) UIPopoverController *popoverController;
@property (retain) OrderDataSource *dataSource;

- (IBAction) cashOrder;
- (IBAction) selectOrder;

- (void) onOrderUpdated;
- (void) prepareForNewOrder;
- (void) setupStartScreen;
- (void) setupScreenForNewOrder;

@end

