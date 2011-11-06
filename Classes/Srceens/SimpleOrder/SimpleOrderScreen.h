//
//  SimpleOrderScreen.h
//  HarkPad
//
//  Created by Willem Bison on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuTreeView.h"
#import "Order.h"

@interface SimpleOrderScreen : UIViewController <MenuTreeViewDelegate, UITableViewDataSource> {
    Order * _order;
}

@property (retain) IBOutlet MenuTreeView *productView;
@property (retain) IBOutlet UITableView *orderView;
@property (retain) Order *order;

- (IBAction) cashOrder;
- (IBAction) selectOrder;
@end

