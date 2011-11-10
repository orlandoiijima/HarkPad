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

@interface SimpleOrderScreen : UIViewController <MenuTreeViewDelegate, UITableViewDataSource, SelectItemDelegate> {
    Order * _order;
}

@property (retain) IBOutlet MenuTreeView *productView;
@property (retain) IBOutlet UITableView *orderView;
@property (retain) IBOutlet UIButton *userButton;
@property (retain) Order *order;
@property (retain) UIPopoverController *popoverController;

- (IBAction) cashOrder;
- (IBAction) selectOrder;
- (IBAction) selectUser;

@end

